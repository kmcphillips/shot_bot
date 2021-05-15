# frozen_string_literal: true
class TwitterSearchBot < BaseBot
  def notification
    {
      title: config[:title],
      message: response.new_tweets.join("\n"),
    }
  end

  def build_response
    TwitterSearchBot::Response.new(
      search: config[:search],
      db_file_path: Global.root.join("data", config[:db_file_name])
    )
  end

  def bot_name
    "Twitter search for: #{ config[:search] }"
  end

  class Response
    attr_reader :result, :search, :db_file_path, :new_tweets

    def initialize(search:, db_file_path:)
      @result = nil
      @search = search
      @db_file_path = db_file_path
      @new_tweets = []
    end

    def fetch
      if File.exists?(db_file_path)
        previous = File.read(db_file_path)
        previous_tweets = previous.split("\n")
        current = `snscrape twitter-search "#{ search }"`
        current_tweets = current.split("\n")
        @new_tweets = current_tweets - previous_tweets
        File.write(db_file_path, current)
      else
        current = `snscrape twitter-search "#{ search }"`
        current_tweets = current.split("\n")
        File.write(db_file_path, current)
      end

      success?
    end

    def success?
      true # TODO
    end

    def error_message
      "" # TODO always success
    end

    def found?
      new_tweets.any?
    end

    def to_s
      rescue_found = found? rescue nil
      "#<#{ self.class } found=#{ rescue_found } #{ new_tweets.count } new #{ 'tweet'.pluralize(new_tweets.count) } for search: \"#{ search }\">"
    end
  end
end
