#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'set'
require './toolHelpers'

program :version, '0.0.1'
program :description, 'ECHO Collection Explorer'
global_option '-V','--verbose','Enable verbose mode'
global_option '-G','--granules','Granules mode'
global_option '-D','--dif','DIF mode'


def get_all_rows table_info, options
  stmt = "select * from #{table_info[0]}"
  if options.provider && options.granules
    stmt << " where collection_id LIKE '%#{options.provider}'"
  elsif options.provider
    stmt << " where provider = '#{options.provider}'" if options.provider 
  end
  stmt
end

command :get do |c|
  c.syntax = 'echocollectiontool get ECHO_COLLECTION_ID'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb get C1346-NSIDCV0'
  c.action do |args, options|
    table_info = ToolHelpers.get_table_info options
    count = 0
    ToolHelpers.get_db(options).execute("select * from #{table_info[0]} WHERE #{table_info[1]} LIKE \'%#{args[0]}%\'") do |row|
      3.times { puts "--------"}
      puts row[table_info[2]]
      3.times { puts "--------"}
      count += 1
    end
    puts "total count: #{count}"
  end
end

command :pull_fields do |c|
  c.option '-i', '--ignore_case', 'ignore case when summarizing'
  c.option '-p STRING', '--provider STRING', String, 'provider name'
  c.option '--outfile STRING', String, 'output file'
  c.action do |args, options|
    table_info = ToolHelpers.get_table_info options
    collection_values = Hash.new

    ToolHelpers.get_db(options).execute(get_all_rows table_info, options) do |row|
    end
  end
end


command :summarize do |c|
  c.syntax = 'echocollectiontool summarize'
  c.example 'Try this', 'be ruby ./echocollectiontool.rb summarize "/Collection/CollectionDataType"'
  c.option '--outfile STRING', String, 'output file'
  c.option '-i', '--ignore_case', 'ignore case when summarizing'
  c.option '-p STRING', '--provider STRING', String, 'provider name'
  c.action do |args, options|

    table_info = ToolHelpers.get_table_info options

    options.default :outfile => nil
    node_instances = Array.new
    value_hash = Hash.new(0)
    collection_values = Hash.new
    
    ToolHelpers.get_db(options).execute(get_all_rows table_info, options) do |row|
      fields = ToolHelpers.find_xpath(args[0], row[table_info[2]])
      # if (fields.length == 0 && options.granules)
      #   puts "#{row[1]} missing #{args[0]}"
      # end
      fields.each do |node|
          # puts "#{row[1]} FOUND #{args[0]}"
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
    value_hash.each {|key, value| output << "#{key} ||| #{value}\n"}
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
    puts "-------------------"
    puts "#{args[0]}: (#{node_instances.length})"

    if options.outfile
      File.open(options.outfile, "w") do |aFile|
        aFile.puts output
      end
    else
      puts output
    end

  end


  end