load 'image.rb'
class List
  include DataMapper::Resource

  property :creator,    String, :key => true
  property :slug,       String, :key => true
  property :users,      Json
  property :created_at, DateTime

  has n, :images

  def self.sync(creator, slug)
    require 'open-uri'
    # TODO: multiple paged lists
    contents = JSON.parse(open("https://api.twitter.com/1/lists/members.json?slug=#{slug}&owner_screen_name=#{creator}").read)
    list = List.get(creator, slug) || List.new(:slug => slug, :creator => creator)
    list.users = contents['users'].map{|u| u['screen_name']}.sort
    list.save

    list
  end

  def member?(nickname)
    users.include?(nickname) || creator == nickname
  end
end

DataMapper.auto_upgrade!
