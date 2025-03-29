class User < ApplicationRecord
  has_many :invitations
  has_many :viewing_parties, through: :invitations 

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: { require: true }
  has_secure_password
  has_secure_token :api_key

end