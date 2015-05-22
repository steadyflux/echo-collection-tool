class ToolHelpers

  def self.get_db options
    file_name = 'echo_collections.db'

    if options.granules 
      file_name = 'echo_granules.db'
    elsif options.dif
      file_name ='dif_records.db'
    end
    SQLite3::Database.new(file_name)
  end

  def self.get_table_info options
    info = ['collections', 'collection_id', 3]
    if options.granules 
      info = ['granules', 'granule_id', 4]
    elsif options.dif
      info = ['difs', 'entry_id', 1]
    end
    info
  end

  def self.find_xpath xpath, xml
    doc = Nokogiri::XML(xml)
    doc.remove_namespaces!
    doc.xpath(xpath)
  end

  def self.get_clean_string s
    s = URI.escape s.strip
    s = s.gsub(/[\/]/, '%2F')
  end
end