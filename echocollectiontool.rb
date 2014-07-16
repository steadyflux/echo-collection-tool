#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'set'

program :version, '0.0.1'
program :description, 'ECHO Collection Explorer'
global_option '-V','--verbose','Enable verbose mode'

db = SQLite3::Database.new('echo_collections.db')

def find_xpath xpath, xml
  doc = Nokogiri::XML(xml)
  doc.remove_namespaces!
  doc.xpath(xpath)
end

command :get do |c|
  c.syntax = 'echocollectiontool get ECHO_COLLECTION_ID'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb get C1346-NSIDCV0'
  c.action do |args, options|
    db.execute("select * from collections WHERE collection_id LIKE \'%#{args[0]}%\'") do |row|
      puts row[2]
    end
  end
end

command :summarize do |c|
  c.syntax = 'echocollectiontool summarize'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb summarize "/Collection/CollectionDataType"'
  c.option '--outfile STRING', String, 'output file'
  c.option '-i', '--ignore_case', 'ignore case when summarizing'
  c.action do |args, options|
    options.default :outfile => nil
    node_instances = Array.new
    value_hash = Hash.new(0)
    collection_values = Hash.new
    db.execute("select * from collections") do |row|
      fields = find_xpath(args[0], row[2])
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

    value_hash.each {|key, value| output << "#{key} : #{value}\n" }
    output << "-------------------\n"
    if options.verbose
      output <<  "Summary:\n"
      collection_values.each {|key, value| output << "#{key} : #{value.inspect}\n" }
    end

    if options.outfile
      File.open(options.outfile, "w") do |aFile|
        aFile.puts output
      end
    else
      puts output
    end

  end
end