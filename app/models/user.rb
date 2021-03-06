class User < ActiveRecord::Base
  rolify
  attr_accessible :provider, :uid, :name, :email, :oauth_token, :oauth_token_expires, :oauth_token_expires_at, :address, :latitude, :longitude, :country_code
  validates :name, presence: true
  #validates :address, presence: true
  #validates :latitude, presence: true
  #validates :longitude, presence: true

  has_many :publications

  after_validation :reverse_geocode

  reverse_geocoded_by :latitude, :longitude do |user,results|
    geo = results.try(:first)
    user.update_attribute :country_code, geo.country_code if geo.present?
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

  def extra_small_image
    "http://graph.facebook.com/#{self.uid}/picture?width=30&height=30"
  end

  def small_image
    "http://graph.facebook.com/#{self.uid}/picture?width=50&height=50"
  end

  def medium_image
    "http://graph.facebook.com/#{self.uid}/picture?width=250&height=150"
  end

  def large_image
    "http://graph.facebook.com/#{self.uid}/picture?width=600&height=600"
  end

  def friend_list
    graph.get_connections("me", "friends").map{ |t| { id: t['id'], name: t['name'] } }
  end

  def mutual_friends uid
    graph.get_connections("me", "mutualfriends/#{uid}")
  end

  def transactions
    @transaction ||= rand(20)
  end

  def friends_in_common
    @friends_in_common ||= rand(20)
  end

  private

  def graph
    @graph ||= Koala::Facebook::API.new(self.oauth_token)
  end

end
