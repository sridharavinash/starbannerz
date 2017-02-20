#!/usr/bin/env ruby

require 'octokit'
require 'rainbow'
require 'yaml'
require 'open-uri'

def setup_client(login)
  if File.exists?("config.yml")
    config = YAML.load_file("config.yml")
    client_id_from_yml = config["client_id"]
    client_secret_from_yml = config["client_secret"]
  else
    puts "No config.yml!"
    exit 1
  end
  client = Octokit::Client.new(
    :client_id => client_id_from_yml,
    :client_secret => client_secret_from_yml,
  )
  client
end

def get_starred_repos(client, login)
  repos = client.starred(login, :per_page => 100, :direction => "asc")
  langs = repos
          .to_a
          .reject{|x| x.language == nil}
          .map {|x| x.language}
  langs
end

def get_github_languages_yml()
  if File.exists?("languages.yml")
    return
  end
  yml_uri = open("https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml")
  IO.copy_stream(yml_uri, "languages.yml")
end

def main()
  client = setup_client(ARGV[0])

  get_github_languages_yml

  parsed = YAML.load_file("languages.yml")

  block = "  "
  get_starred_repos(client, ARGV[0]).each_with_index do |x, index|
    if parsed.has_key? x
      color  = parsed[x]["color"]
    else
      color = "#000000"
    end
    begin
      print Rainbow(block).bg(color).bright
    rescue NoMethodError
      print Rainbow(block).bg(:black)
    end
  end
  puts
end

if ! ARGV[0]
  puts "usage: starbannerz.rb <github_username>"
else
  main()
end
