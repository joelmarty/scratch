#!/usr/bin/env ruby
# coding: utf-8
#
# This script adds SVN keyword tags Revision and Date to XML/HTML files, just below the XML header or the DOCTYPE declaration.
# doctype because that's how our "embedded" html pages need to be.
# if one of both headers is not detected, it will assume it's XML and add it.

XML_MARKUP = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
SVN_MARKUP = "<!--\n$Revision$\n$Date$\n-->"
REV_PAT = /\$Revision\$/
SEARCH_PAT = /(<!DOCTYPE(.*?)\">|<\?xml.*\?>)/mi

usage = "usage: \n svn_markup.rb \"/path/to/templates\""

# just checking script was called with path argument
unless ARGV.length >= 1
  puts "Wrong number of arguments"
  puts usage
  exit
end

path = ARGV[0]

# is the given path real?
if not File.directory? path
  puts "path is invalid"
  exit
end

dir = Dir.new path

dir.each do |filename|
  #building absolute path, is there a better way to do this?
  absolute_path = %{#{dir.path}#{filename}}
    unless File.directory? File.new absolute_path
      begin
        content = File.read absolute_path
        unless REV_PAT.match content
          if SEARCH_PAT.match content
            replace = content.gsub(SEARCH_PAT) {|match| "#{match}\n#{SVN_MARKUP}"}
            message = "File #{filename} was tagged below header"
          else
            replace = "#{XML_MARKUP}\n#{SVN_MARKUP}\n#{content}"
            message = "File #{filename} was tagged with new header"
          end
          File.open(absolute_path, 'w') { |file| file.write(replace) }
          puts message
        else
          puts "#{filename} is already tagged"
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end
end
