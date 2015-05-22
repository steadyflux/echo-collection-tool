require 'rubygems'
require 'rest_client'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'yaml'

program :version, '0.0.1'
program :description, 'GCMD Data Retrieval Tool'
global_option '-V','--verbose','Enable verbose mode'
global_option '--quick_test', 'get first result'

# Retrieve ID List
# http://gcmdservices.gsfc.nasa.gov/mws/entryids/dif?query=%5B*%5D

@cnf = YAML.load_file('ect.config.yml')

command :get_difs do |c|
  c.syntax = 'retrieveGcmdData get_difs'
  c.option '--inputFile STRING', String, 'input dif id list'
  c.option '--db_out_file_name STRING', String, 'output database file name (gcmd_difs.db by default)'
  c.option '--startLine INTEGER', Integer, 'start line'
  c.action do |args, options|
    startLine = (options.startLine || 0)
    db_out_file_name = options.db_out_file_name || 'gcmd_difs.db'
    # File.delete(db_out_file_name) if File.exist?(db_out_file_name)
    db = SQLite3::Database.new(db_out_file_name)

    # rows = db.execute <<-SQL
    #   create table difs (
    #     entry_id varchar(255),
    #     dif_xml text
    #   );
    # SQL

    lines = []
    errors = []
    count = 0
    File.readlines(options.inputFile).each do |eid|
      count += 1
      if count > startLine
        begin
          entry = eid.strip.gsub("[","%5B").gsub("]","%5D")
          
          sleep(1)
          
          puts "record[#{count}]: #{entry}" if options.verbose

          resource = RestClient::Resource.new(
            @cnf['base_dif_url'] + entry,
            @cnf['urs_user'],
            @cnf['urs_pw']
          )

          response = resource.get

          record = [
            eid.strip,
            response.body.strip
          ]

          db.execute "insert into difs values ( ?, ?)", record
          
        rescue Exception => e
          puts " caught exception #{e} for #{eid.strip}! carrying on "
          errors << " caught exception #{e} for #{eid.strip}! carrying on "
          unless agree("should i continue? (yes or no)")
            raise
          end
        end
      end
    end

    puts "finishing up ... "
    errors.each do |e|
      puts "#{e}"
    end    
  end
end

command :get_serfs do |c|
  c.syntax = 'retrieveGcmdData get_serfs'
  c.option '--inputFile STRING', String, 'input serf id list'
  c.option '--db_out_file_name STRING', String, 'output database file name (gcmd_serfs.db by default)'
  c.action do |args, options|
    db_out_file_name = options.db_out_file_name || 'gcmd_serfs.db'
    File.delete(db_out_file_name) if File.exist?(db_out_file_name)
    db = SQLite3::Database.new(db_out_file_name)
    

    rows = db.execute <<-SQL
      create table serfs (
        entry_id varchar(255),
        serf_xml text
      );
    SQL

    lines = []
    File.readlines(options.inputFile).each do |line|
      lines << line
    end

    errors = []
    progress lines do |eid|
        begin
          entry = eid.strip.gsub("[","%5B").gsub("]","%5D")
          puts "record: #{eid.strip}" if options.verbose
          resource = RestClient::Resource.new(
            @cnf['base_serf_url'] + entry,
            @cnf['urs_user'],
            @cnf['urs_pw']
          )
          response = resource.get
          record = [
            eid.strip,
            response.body.strip
          ]
          db.execute "insert into serfs values ( ?, ?)", record
          sleep(2)
        rescue Exception => e
          errors << " caught exception #{e} for #{eid.strip}! carrying on "
          retry
        end
    end
    puts "finishing up ... "
    errors.each do |e|
      puts "#{e}"
    end
  end
end