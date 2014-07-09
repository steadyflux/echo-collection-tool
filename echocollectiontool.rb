#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'set'

program :version, '0.0.1'
program :description, 'ECHO Collection Explorer'

db = SQLite3::Database.new('echo_collections.db')

def find_xpath xpath, xml
  doc = Nokogiri::XML(xml)
  doc.remove_namespaces!
  doc.xpath(xpath)
end


command :summarize do |c|
  c.syntax = 'echocollectiontool summarize'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb summarize "/Collection/CollectionDataType"'
  c.option '--outfile STRING', String, 'output file'
  c.action do |args, options|
    options.default :outfile => nil
    node_instances = Array.new
    value_set = Set.new
    value_hash = Hash.new(0)
    db.execute("select * from collections") do |row|
    # db.execute("select * from collections WHERE collection_xml like \'%#{args[0]}%\'") do |row|
      fields = find_xpath(args[0], row[2])
      fields.each do |node|
          node_instances << node
          value_set.add(node)
          value_hash[node.text.to_s.downcase.split.join(" ")] = value_hash[node.text.to_s.downcase.split.join(" ")] + 1
          # node_instances << node.text
          # value_set.add(node.text)
          # value_hash[node.text] = value_hash[node.text] + 1
      end
    end
    puts "-------------------"
    puts "#{args[0]}: (#{node_instances.length})"
    # value_set.each do |x| 
    #   puts x
    #   puts ':::'
    # end

    output = ""

    # value_set.each { |x| output << x << "\n"}
    value_hash.each {|key, value| output << "#{key} : #{value}\n" }
    output << "-------------------\n"
    output <<  "Summary: #{args[0]}: (#{node_instances.length})"

    if options.outfile
      File.open(options.outfile, "w") do |aFile|
        aFile.puts output
      end
    else
      puts output
    end

  end
end