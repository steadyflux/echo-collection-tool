#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'sqlite3'
require 'commander/import'
require 'set'
require './toolHelpers'


program :version, '0.0.1'
program :description, 'ECHO Snippet Builder'
global_option '-V','--verbose','Enable verbose mode'
global_option '-G','--granules','Granules mode'
global_option '-D','--dif','DIF mode'

  command :snippet do |c|
    c.syntax = 'snippetBuilder snippet'
    c.example 'Try this', 'be ruby ./snippetBuilder.rb snippet "/Collection/CollectionDataType"'
    c.option '--find_any'
    c.action do |args, options|
      options.default :outfile => nil
      table_info = ToolHelpers.get_table_info options
      puts get_random_snippet(ToolHelpers.get_db(options), args[0], table_info[2], table_info[0], options.find_any)
    end
  end

  def get_random_snippet(db, xpath, xml_col, table, find_first = false)
    rand_row = find_first ? 1 : Random.rand(3700)
    puts "finding any ... #{table} " if find_first
    count = 0
    output = ""
    db.execute("select * from #{table}") do |row|
      fields = ToolHelpers.find_xpath(xpath, row[xml_col])
      fields.each do |node|
        count += 1
        if count == rand_row
          output << xpath << " ||| " << row[0] << " ||| " 
          output << row[2] if xml_col == 4
          output << "\n" << node.to_s << "\n\n----------\n\n"
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
    c.syntax = 'snippetBuilder compile_snippets -G --inputFile file --outfile file'
    c.option '--outfile STRING', String, 'output file'
    c.option '--inputFile STRING', String, 'input file'
    c.action do |args, options|

      options.default :outfile => nil
      output = ""
      
      db = ToolHelpers.get_db(options)
      table_info = ToolHelpers.get_table_info options
      
      # for each xpath in the input file
      print "Working"

      File.readlines(options.inputFile).each do |xpath|
        begin
          print "."
          output << get_random_snippet(db, xpath.strip,  table_info[2], table_info[0])
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