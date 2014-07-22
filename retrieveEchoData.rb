
require 'rest_client'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'


program :version, '0.0.1'
program :description, 'ECHO Data Retriever'
global_option '-V','--verbose','Enable verbose mode'

# ::::::::::::::::::::::::::::::::::::
# Set up the query

BASE_URL = 'https://api.echo.nasa.gov/catalog-rest/echo_catalog/'

#token from 6.5.2014
# generatetoken.sh ops ~/work/bin/gentoken.xml
header = { 'Echo-Token' => 'NOT A REAL TOKEN'}


command :collections do |c|
  c.syntax = 'retrieveEchoData collections'
  c.example 'Try this', 'be ruby ./retrieveEchoData.rb collections'
  c.option '--db_file_name STRING', String, 'database file name (echo_collections.db by default)'
  c.option '--quick_test', 'get first page with 10 results'

  c.action do |args, options|
    db_file_name = options.db_file_name || 'echo_collections.db' 
    # ::::::::::::::::::::::::::::::::::::
    # Set up the db
    File.delete(db_file_name) if File.exist?(db_file_name)

    db = SQLite3::Database.new(db_file_name)

    rows = db.execute <<-SQL
      create table collections (
        collection_id varchar(255),
        insert_date varchar(255),
        collection_xml text
      );
    SQL

    # ::::::::::::::::::::::::::::::::::::
    # Build the query

    params = {  
     :page_size => options.quick_test ? 10 : 2000,
     :page_num => 1
    }

    resource = RestClient::Resource.new(
      BASE_URL + 'datasets.echo10',
      # :headers => header,
      :timeout => nil
    )    

    # ::::::::::::::::::::::::::::::::::::
    # loop-de-loop

    keep_going = true
    while keep_going do
      response = resource.get :params => params
        puts "Processing Page: #{params[:page_num]}" if options.verbose
        params[:page_num] = params[:page_num] + 1 

        xml_doc = Nokogiri::XML(response.body)
        xml_doc.xpath("//result").to_a.each do |result|

          collection_id = result["echo_dataset_id"]

          result.xpath("Collection").to_a.each do |collection|
            record = [
              collection_id,
              Time.now.asctime,
              collection.to_s
            ]
            puts "record: #{collection_id}" if options.verbose
            db.execute "insert into collections values ( ?, ?, ? )", record
          end
        end
        keep_going = options.quick_test ? false : ("false" == response.headers[:echo_cursor_at_end])
    end
  end
end


  command :granules do |c|
    c.syntax = 'retrieveEchoData some granules'
    c.example 'Try this', 'be ruby ./retrieveEchoData.rb granules --collection_id C28466914-LPDAAC_ECS -V'
    c.option '--db_out_file_name STRING', String, 'database file name (echo_granules.db by default)'
    c.option '--collection_id STRING', String, 'get granules from a specific collection'
    c.action do |args, options|
      
      # ::::::::::::::::::::::::::::::::::::
      # Set up the db
      db_out_file_name = options.db_out_file_name || 'echo_granules.db' 
      File.delete(db_out_file_name) if File.exist?(db_out_file_name)

      db = SQLite3::Database.new(db_out_file_name)

      rows = db.execute <<-SQL
        create table granules (
          granule_id varchar(255),
          granule_ur varchar(255),
          insert_date varchar(255),
          granule_xml text
        );
      SQL

      if options.collection_id
        get_granules_from_collection db, options, options.collection_id, 200    
      else

        puts 'not yet supported'
      end   
  end
end

def get_granules_from_collection db, options, collection_id, num_granules
    params = { 
      "echo_collection_id[]" => collection_id,
      :page_size => num_granules,
      :page_num => 1
    }

    resource = RestClient::Resource.new(
      BASE_URL + "granules.echo10",
      # :headers => header,
      :timeout => nil
    ) 
    
    response = resource.get :params => params
    puts "Processing Page: #{params[:page_num]}" if options.verbose

    xml_doc = Nokogiri::XML(response.body)
    xml_doc.xpath("//result").to_a.each do |result|

      granule_id = result["echo_granule_id"]
      granule_ur = result.xpath(".//GranuleUR").text
      record = [
        granule_id,
        granule_ur,
        Time.now.asctime,
        result.xpath(".//Granule").to_s
      ]
      puts "record: #{granule_id}, #{granule_ur}" if options.verbose
      db.execute "insert into granules values ( ?, ?, ?, ? )", record
    end
end


