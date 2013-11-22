#!/usr/bin/env ruby

require "thor"
require "httparty"
require "pp"
require "json"
require "yaml" 
require "active_support/all"

class Trakt
  include HTTParty
  base_uri 'api.trakt.tv'
end

class TraktCLI < Thor
  class_option :verbose, :type => :boolean

  def initialize(*args)
    super

    config = YAML.load_file( "config.yaml" )
    @api_key = config["trakt"]["api_key"]
  end

  desc "track SHOW_NAME", "Start tracking SHOW_NAME"
  def track(show_name)
    puts "Start tracking #{show_name}"
  end

  desc "untrack SHOW_NAME", "Stop tracking SHOW_NAME"
  def untrack(show_name)
    puts "Untracking #{show_name}"
  end

  desc "list USERNAME", "List all tracking shows for USERNAME"
  def list_shows(username)
    puts "Listing all tracking shows for user #{username}"

    shows = Trakt.get("/user/library/shows/watched.json/#{@api_key}/#{username}")
    shows.each do |show|
      puts show["title"]
    end
  end

  desc "upcoming USERNAME", "List all upcoming shows for USERNAME"
  option :today, :aliases => :t
  def upcoming(username)
    puts "Listing upcoming shows"

    calendar_path = "/user/calendar/shows.json"
    calendar_path = options[:today] ? calendar_path + "/#{@api_key}/#{username}/today/1" : calendar_path + "/#{@api_key}/#{username}"

    calendar = Trakt.get(calendar_path)
    calendar.each do |termin|
      print "\n"
      print termin["date"] + "\n"
      
      termin["episodes"].each do |show|
        time = show["episode"]["first_aired_utc"]
        time_localized = Time.at(time).in_time_zone("Europe/Zurich").strftime("%d.%m.%Y %H:%M")

        print time_localized
        print " " + show["show"]["title"] + " - S"
        print show["episode"]["season"]
        print "E"
        print show["episode"]["number"]
        print "\n"
      end
    end
  end
end
 
TraktCLI.start(ARGV)

