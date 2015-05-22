#!/usr/bin/env ruby

require 'commander/import'
require 'rest_client'
require 'nokogiri'
require 'sqlite3'
require 'addressable/uri'
require './toolHelpers'
require 'yaml'

program :version, '0.0.1'
program :description, 'Collection Ingest Tool'
global_option '-V','--verbose','Enable verbose mode'

@cnf = YAML.load_file('ect.config.yml')
header = { 'Echo-Token' => @cnf['ingest_token']}
ingest_url = @cnf['base_ingest_url']+@cnf['ingest_provider']+'/datasets/'

command :test do |c|
  c.action do |args, options|
    uri = Addressable::URI.parse(@cnf['base_ingest_url'])
    s = "Long-Term Ecological Research (LTER)/AND012: Tree Permanent Plots of the Pacific Northwest"
    
    s = URI.escape s
    
    puts s.gsub(/[\/]/, '%2F')
  end
end

command :clear_all do |c|
  c.syntax = 'ingesttool clear_all'
  c.example 'Try this', 'be ruby ./ingesttool.rb clear_all'
  c.action do |args, options|

    confirm = choose("Are you SURE?", "YES", "er ... maybe not")
    
    #get all collections
    params = {  
     :page_size => 2000,
     :page_num => 1,
     :provider_id => @cnf['ingest_provider']
    }

    resource = RestClient::Resource.new(
      @cnf['base_cmr_search_url'] + 'collections',
      :headers => header,
      :timeout => nil
    )
    response = resource.get :params => params    
    count = 0
    Nokogiri::XML(response.body).xpath("//name").to_a.each do |result|
      count += 1
      print "#{count}. #{result.text}"

      if confirm == "YES"
        # if count > 1000
          route = ingest_url+URI.escape(result.text)
          begin
            RestClient.delete route, header  
            puts "... DELETED"
          rescue Exception => e
            puts e.response
          end
        # end
      else
        puts
      end
    end
    if confirm == "YES"
      puts "ALL GONE"
    else
      puts "probably for the best..."
    end
  end
end


command :add_single_dif do |c|
  c.syntax = 'ingesttool add_single_dif'
  c.example 'Try this', 'be ruby ./ingesttool add_single_dif C1346-NSIDCV0'
  c.action do |args, options|
    options.dif = true
    table_info = ToolHelpers.get_table_info options
    ToolHelpers.get_db(options).execute("select * from #{table_info[0]} WHERE #{table_info[1]} LIKE \'%#{args[0]}%\'") do |row|
      fields = ToolHelpers.find_xpath('//Entry_Title', row[table_info[2]])
      datasetId = ToolHelpers.get_clean_string fields.text
      route = ingest_url+datasetId
      puts route
      begin
        RestClient.put route, row[table_info[2]], header.merge({"Content-Type" => 'application/xml', "Xml-Mime-Type" => 'application/dif+xml'})
      rescue => e
        puts e.response
      end
    end
  end
end

command :add_difs do |c|
  c.syntax = 'ingesttool add_difs'
  c.example 'Try this', 'be ruby ./ingesttool add_difs'
  c.option '--inputFile STRING', String, 'input dif id list'
  c.option '--startLine INTEGER', Integer, 'start line'
  c.option '--outputFile STRING', String, 'output File'
  c.action do |args, options|
    options.dif = true
    table_info = ToolHelpers.get_table_info options
    prng1 = Random.new()
    count = (options.startLine || 0)
    linect = 0
    outfile = File.open(options.outputFile, "w") if options.outputFile
    File.readlines('dif_id_list').each do |eid|
      linect += 1
      if linect > (options.startLine || 0)
        # if prng1.rand(1000) > 900
          count += 1
          puts "#{count}. #{eid.chop!}"
          outfile.puts "#{count}. #{eid}" if outfile
          ToolHelpers.get_db(options).execute("select * from #{table_info[0]} WHERE #{table_info[1]} LIKE \'%#{eid}%\'") do |row|
            fields = ToolHelpers.find_xpath('//Entry_Title', row[table_info[2]])
            datasetId = ToolHelpers.get_clean_string fields.text
            unless datasetId.include? ']' 
              route = ingest_url+datasetId
              puts route if options.verbose

              begin
                tries ||= 2
                RestClient.put route, row[table_info[2]], header.merge({"Content-Type" => 'application/xml', "Xml-Mime-Type" => 'application/dif+xml'})
              rescue => e
                retry unless (tries -= 1).zero?
                # unless agree("tried twice, should i continue? (yes or no)")
                #   raise
                # end
                puts e.response
                outfile.puts e.response if outfile
              end
              outfile.flush if outfile
            end
          # end
        end
      end
    end
    outfile.close if outfile
  end
end