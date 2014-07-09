
require 'rest_client'
require 'nokogiri'
require 'sqlite3'

# ::::::::::::::::::::::::::::::::::::
# Set up the query

base_url = 'https://api.echo.nasa.gov/catalog-rest/echo_catalog/datasets.echo10'

params = {  
 :page_size => 2000,
 :page_num => 1
}

#token from 6.5.2014
# generatetoken.sh ops ~/work/bin/gentoken.xml
header = { 'Echo-Token' => 'NOT A REAL TOKEN'}

resource = RestClient::Resource.new(
  base_url,
  # :headers => header,
  :timeout => -1
  )


# ::::::::::::::::::::::::::::::::::::
# Set up the db

File.delete('echo_collections.db')

db = SQLite3::Database.new('echo_collections.db')

rows = db.execute <<-SQL
  create table collections (
    collection_id varchar(255),
    insert_date varchar(255),
    collection_xml text
  );
SQL

# ::::::::::::::::::::::::::::::::::::

keep_going = true
while keep_going do
  response = resource.get :params => params
    puts "Processing Page: #{params[:page_num]}"
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
        puts "record: #{collection_id}"
        db.execute "insert into collections values ( ?, ?, ? )", record
      end
    end
    # keep_going = false
    keep_going = ("false" == response.headers[:echo_cursor_at_end])
end


