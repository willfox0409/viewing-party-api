class User < ApplicationRecord
  has_many :invitations
  has_many :viewing_parties, through: :invitations 

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: { require: true }
  has_secure_password
  has_secure_token :api_key

  def hosted_parties #filters just the invitations where user is host
    invitations.where(host: true).map do |invitation|  
      invitation.viewing_party #get the viewing party for each of those invitations 
    end

  end

  def invited_parties #filters the invitations where user isn't the host 
    invitations.where(host: false).map do |invitation|  
      invitation.viewing_party #get the viewng party for each of those invitations 
    end
  end
end