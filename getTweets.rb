require 'rubygems'
require 'twitter'
require 'json'

client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'pMBTGFYoRSG5Q6mTspKm89zSy'
  config.consumer_secret = 'xoEvBkzipl1iobLFsXSNsLNh0VRxugukCllzNrmxbrkEo0uOcC'
  config.access_token = '594286403-Tkacwv9rSFNBwxubgKvcDCeK8PmEmN5eKWLI43XA'
  config.access_token_secret = 'HG3nqJjubQErKLvLqo0SJYeugPKsrqaWPX0jqfPzgw8Zc'
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id-1, &block)
end

def client.get_all_tweets(user,filename)
  file = File.open("su.txt","w")
  count = 1
  collect_with_max_id do |max_id|
    options = {count:200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    tweets = user_timeline(user,options)
    tweets.each do |tweet|
      file.write(tweet.text)
      file.write("\n")
      puts count
      count += 1
    end
  end
  file.close unless file == nil
end

# get all tweets of a user
username = "sunnyunyChu"
client.get_all_tweets(username,username)

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
