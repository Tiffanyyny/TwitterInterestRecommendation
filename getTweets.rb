require 'rubygems'
require 'twitter'
require 'json'
require 'sqlite3'

class CrawlTweets
  attr_accessor :client, :users
  # :DB
  
  def initialize(file_path)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = 'JGm4c5dQYI2ByxLpnSeKd0lTD'
      config.consumer_secret = 'TNYKOeu6D6Qbs4EnsCN8XGxxXJruNST5rFiagISJaMaiQGjQOU'
      config.access_token = '594286403-Tkacwv9rSFNBwxubgKvcDCeK8PmEmN5eKWLI43XA'
      config.access_token_secret = 'HG3nqJjubQErKLvLqo0SJYeugPKsrqaWPX0jqfPzgw8Zc'
    end
    # File.delete(db_name) if File.exists?db_name
    # @DB = SQLite3::Database.new(db_name)
    @users = []
    read_users(file_path)
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id-1, &block)
  end

  def get_all_tweets(user)
    file = File.new("Tweets/"+user+".txt","w")
    # @DB.execute("CREATE TABLE user_tweets(user_name, tweet UNIQUE ON CONFLICT IGNORE, timestamp)")
    # insert_query = "INSERT INTO user_tweets(user_name, tweet, timestamp) VALUES(?,?,?)"
    collect_with_max_id do |max_id|
      options = {count:150, include_rts: true}
      options[:max_id] = max_id unless max_id.nil?
      begin
        tweets = @client.user_timeline(user,options)
      rescue Twitter::Error::TooManyRequests => error
        puts "Too many requests"
        puts error.rate_limit.reset_in
        sleep error.rate_limit.reset_in+1
        retry
      end
      tweets.each do |tweet|
        # @DB.execute(insert_query, @user, tweet.text, tweet.created_at.to_s)
        file.write(tweet.text)
        file.write("\n")
      end
    end
    file.close unless file == nil
    return 1
  end
  
  def read_users(file_path)
    f = File.new(file_path,"r")
    f.each_line {|line|
        @users.push line
    }
  end
  
  def user_tweets
    @users.each do |user|
      get_all_tweets(user)
    end
  end
  
end

# get all tweets of a user
userTweets = CrawlTweets.new("user_list.csv")
userTweets.user_tweets

# user suggestion
# file = File.new("photograph_users.txt","w")
# suggested_users = client.suggestions("photography",options = {})
# suggested_users.users.each do |user|
#   file.write(user.name)
#   file.write("\n")
# end
# file.close unless file == nil

# handle rate limit
# while true do
#   suggested_users.users.each do |user|
#     file.write(user.name)
#     file.write("\n")
#   end
# rescue Twitter::Error::TooManyRequests => error
#   sleep error.rate_limit.reset_in+1
#   retry
# end
# end
# file.close unless file == nil

# Twitter Search
# client.search("to:justinbieber marry me", result_type: "recent").take(3).each do |tweet|
#   puts tweet.text
# end
