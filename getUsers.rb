require 'rubygems'
require 'twitter'
require 'json'
require 'sqlite3'

class CrawlUser
  attr_accessor :client, :DB, :tags
  
  
  def initialize(db_name)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = 'JGm4c5dQYI2ByxLpnSeKd0lTD'
      config.consumer_secret = 'TNYKOeu6D6Qbs4EnsCN8XGxxXJruNST5rFiagISJaMaiQGjQOU'
      config.access_token = '594286403-Tkacwv9rSFNBwxubgKvcDCeK8PmEmN5eKWLI43XA'
      config.access_token_secret = 'HG3nqJjubQErKLvLqo0SJYeugPKsrqaWPX0jqfPzgw8Zc'
    end
    File.delete(db_name) if File.exists?db_name
    @tags = []
    @DB = SQLite3::Database.new(db_name)
  end
  
  # Twitter User-Search
  def get_user()
    read_tags("tags.txt")
    @DB.execute("CREATE TABLE UserTag (user_name UNIQUE ON CONFLICT IGNORE,tag_id)")
    @tags.each_index do |index|
      users = []
      insert_query = "INSERT INTO UserTag (user_name,tag_id) VALUES(?,?)"
      # file = File.new("user_category/"+category+"_users.txt","w")
      for i in 1..10
        options = {count: 20, page: i}
        begin
        users += client.user_search(@tags[index],options)
        rescue Twitter::Error::TooManyRequests => error1
          sleep error1.rate_limit.reset_in+1
          retry
        rescue Twitter::Error::ServiceUnavailable => error2
          sleep error2.rate_limit.reset_in+1
          retry
        end
        users.each do |user|
          if user.lang == "en"
            @DB.execute(insert_query, user.screen_name,index)
            puts user.screen_name
            # file.write(user.name)
            # file.write("\n")
          end
        end
      end
      # file.close unless file == nil
    end
  end
 
  def read_tags(file_path)
    f = File.new(file_path,"r")
    f.each_line {|line|
        @tags.push line
    }
  end
end

db_name = "TwitterData2.sqlite"
crawler = CrawlUser.new(db_name)
crawler.get_user()