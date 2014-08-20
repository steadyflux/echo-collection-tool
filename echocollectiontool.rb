#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'set'

program :version, '0.0.1'
program :description, 'ECHO Collection Explorer'
global_option '-V','--verbose','Enable verbose mode'
global_option '-G','--granules','Granules mode'
global_option '-D','--dif','DIF mode'


def get_db options
  file_name = 'echo_collections.db'

  if options.granules 
    file_name = 'echo_granules.db'
  elsif options.dif
    file_name ='dif_records.db'
  end
  SQLite3::Database.new(file_name)
end

def table_name options
  table = 'collections'
  if options.granules 
    table = 'granules'
  elsif options.dif
    table = 'dif_records'
  end
  table
end

def find_xpath xpath, xml
  doc = Nokogiri::XML(xml)
  doc.remove_namespaces!
  doc.xpath(xpath)
end

command :get do |c|
  c.syntax = 'echocollectiontool get ECHO_COLLECTION_ID'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb get C1346-NSIDCV0'
  c.action do |args, options|
    id_col = options.granules ? 'granule_id' : 'collection_id'
    result_col = options.granules ? 4 : 2
    get_db(options).execute("select * from #{table_name options} WHERE #{id_col} LIKE \'%#{args[0]}%\'") do |row|
      puts row[result_col]
    end
  end
end

command :summarize do |c|
  c.syntax = 'echocollectiontool summarize'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb summarize "/Collection/CollectionDataType"'
  c.option '--outfile STRING', String, 'output file'
  c.option '-i', '--ignore_case', 'ignore case when summarizing'
  c.action do |args, options|
    xml_col = options.granules ? 4 : 2
    options.default :outfile => nil
    node_instances = Array.new
    value_hash = Hash.new(0)
    collection_values = Hash.new
    get_db(options).execute("select * from #{table_name options}") do |row|
      fields = find_xpath(args[0], row[xml_col])
      fields.each do |node|
          node_instances << node          
          v = (options.ignore_case) ? node.text.to_s.downcase.split.join(" ") : node.text.to_s.split.join(" ")
          value_hash[v] = value_hash[v] + 1
          if collection_values[row[0]] 
            collection_values[row[0]] << v
          else
            collection_values[row[0]] = [v]
          end
      end
    end
    puts "-------------------"
    puts "#{args[0]}: (#{node_instances.length})"

    output = ""

    value_hash = value_hash.sort_by {|k, v| v}
    value_hash = Hash[value_hash.to_a.reverse]
    value_hash.each {|key, value| output << "#{key} ||| #{value}\n" }
    output << "-------------------\n"
    if options.verbose
      output <<  "Summary:\n"
      collection_values.each do |key, value|
        value.each do |v|
          output << "#{key} : #{v}\n" 
        end 
        # output << "#{key} : #{value.inspect}\n" 
      end
    end

    if options.outfile
      File.open(options.outfile, "w") do |aFile|
        aFile.puts output
      end
    else
      puts output
    end

  end

  command :snippet do |c|
    c.syntax = 'echocollectiontool snippet'
    c.example 'Try this', 'be ruby ./echocollectiontool.rb snippet "/Collection/CollectionDataType"'
    c.action do |args, options|
      xml_col = options.granules ? 4 : 2
      options.default :outfile => nil
      puts get_random_snippet(get_db(options), args[0], xml_col, table_name(options))
    end
  end

  def get_random_snippet(db, xpath, xml_col, table, find_first = false)
    rand_row = find_first ? 1 : Random.rand(10000)
    count = 0
    output = ""
    db.execute("select * from #{table}") do |row|
      fields = find_xpath(xpath, row[xml_col])
      fields.each do |node|
        count += 1
        if count == rand_row
          output << xpath << " ||| " << row[0] << " ||| " << row[2] << "\n" << node.to_s << "\n\n----------\n\n"
          return output
        end
      end
    end
    # if we get here ... try again with rand_row = 1, but only do it once
    unless find_first 
      puts "trying again: #{xpath}"
      get_random_snippet(db, xpath, xml_col, table, true)
    end
  end

  command :compile_snippets do |c|
    c.syntax = 'echocollectiontool compile_snippets -G --inputFile file --outfile file'
    c.option '--outfile STRING', String, 'output file'
    c.option '--inputFile STRING', String, 'input file'
    c.action do |args, options|
      xml_col = options.granules ? 4 : 2
      options.default :outfile => nil
      output = ""
      db = get_db(options)
      table = table_name(options)
      # for each xpath in the input file
      print "Working"

      File.readlines(options.inputFile).each do |xpath|
        begin
          print "."
          output << get_random_snippet(db, xpath.strip, xml_col, table)
        rescue Exception => e
          puts " caught exception #{e}! carrying on "
        end
      end
      


      puts "Done"
      if options.outfile
        File.open(options.outfile, "w") do |aFile|
          aFile.puts output
        end
      else
        puts output
      end
    end

  end

end