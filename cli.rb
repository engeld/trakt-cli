#!/usr/bin/env ruby

require "thor"
require "httparty"
require "pp"
require "json"
require "yaml" 

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
  def list_tracking_shows(username)
    puts "Listing all tracking shows for user #{username}"

    shows = Trakt.get("/user/library/shows/watched.json/#{@api_key}/#{username}")
    shows.each do |show|
      print "\n"
      print show["title"]
    end
  end

end
 
TraktCLI.start(ARGV)
