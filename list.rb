class List
  include DataMapper::Resource

  property :slug,       String, :key => true
  property :creator,    String, :key => true
  property :users,      Json
  property :created_at, DateTime

  def self.sync(creator, slug)
    require 'open-uri'
    # TODO: multiple paged lists
    contents = JSON.parse(open("https://api.twitter.com/1/lists/members.json?slug=#{slug}&owner_screen_name=#{creator}").read)
    list = List.first(:slug => slug, :creator => creator) || List.new(:slug => slug, :creator => creator)
    list.users = contents['users'].map{|u| u['screen_name']}
    list.save

    list
  end
end

DataMapper.auto_upgrade!
