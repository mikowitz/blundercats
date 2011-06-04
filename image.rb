class Image
  include DataMapper::Resource

  property :id,           Serial
  property :list_slug,    String
  property :list_creator, String
  property :kind,         String
  property :added_by,     String
  property :source_url,   Text
  property :imgur_url,    String
  property :created_at,   DateTime

  validates_uniqueness_of :source_url

  before :save do
    unless imgur_url && imgur_url != ''
      if source_url =~ /imgur.com/
        self.imgur_url = source_url
      else
        img = Imgur::API.new ENV['IMGUR_API_KEY']
        uploaded_img = img.upload_from_url(source_url)
        self.imgur_url = uploaded_img["original_image"]
      end
    end
  end

  def self.random_url(creator, list, kind)
    # TODO: this order by random() won't scale infinitely
    repository(:default).adapter.select("SELECT imgur_url FROM images WHERE kind = ? ORDER BY random() LIMIT 1", kind)[0]
  end
end

DataMapper.auto_upgrade!
