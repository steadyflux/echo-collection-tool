require 'rest_client'
require 'nokogiri'
require 'commander/import'
require 'time'

program :version, '0.0.1'
program :description, 'ECHO NRT Info Retrieval'
global_option '-V','--verbose','Enable verbose mode'

BASE_URL = 'https://api.echo.nasa.gov/catalog-rest/echo_catalog/'

# generatetoken.sh ops ~/work/bin/gentoken.xml
header = { 'Echo-Token' => 'NOT A REAL TOKEN'}


command :collections do |c|
  c.syntax = 'echoNRTinfo show_collections'
  c.example 'Try this', 'be ruby ./echoNRTinfo.rb collections'
  c.action do |args, options|
    puts "NRT Collection Name ||| Youngest Granule Id ||| Granule UR ||| Granule End Time ||| Granule ECHO Insert Time ||| Delay in Minutes" 
    yesterday = (Time.now - 86400).utc.iso8601
    params = {  
     :page_size => 200,
     :page_num => 1,
     :collection_data_type => 'NEAR_REAL_TIME'
    }
    resource = RestClient::Resource.new(
      BASE_URL + 'datasets.echo10',
      # :headers => header,
      :timeout => nil
    )
    response = resource.get :params => params
    xml_doc = Nokogiri::XML(response.body)

    xml_doc.xpath("//result").to_a.each do |result|

      collection_id = result["echo_dataset_id"]
      result.xpath("Collection").to_a.each do |collection|

        get_granules_from_collection options, collection_id, "-start_date", yesterday, collection.xpath("DataSetId").text
      end   
    end
  end
end


def get_total_granules collection_id
  params = { 
    "echo_collection_id[]" => collection_id,
    :page_size => 1,
    :page_num => 1
  } 
  resource = RestClient::Resource.new(
    BASE_URL + "granules.echo10",
    # :headers => header,
    :timeout => nil
  )
  response = resource.get :params => params

  return response.headers[:echo_hits]
end

def get_granules_from_collection options, collection_id, sort_key, since=Time.now, collection_name
  params = { 
    "echo_collection_id[]" => collection_id,
    :page_size => 1,
    :page_num => 1,
    "sort_key[]" => sort_key,
    "updated_since" => since
  }

  resource = RestClient::Resource.new(
    BASE_URL + "granules.echo10",
    # :headers => header,
    :timeout => nil
  ) 
  
  response = resource.get :params => params
  
  xml_doc = Nokogiri::XML(response.body)
  xml_doc.xpath("//result").to_a.each do |result|

    granule_id = result["echo_granule_id"]

    endTime = result.xpath(".//Granule/Temporal/RangeDateTime/EndingDateTime").text
    insertTime = result.xpath(".//Granule/LastUpdate").text

    delay = Time.parse(insertTime) - Time.parse(endTime)

    puts "#{collection_name} ||| #{granule_id} ||| #{result.xpath(".//GranuleUR").text} ||| #{endTime} ||| #{insertTime} ||| #{delay/60}" 

  end
end