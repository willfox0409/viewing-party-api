class Invitation < ApplicationRecord 
  belongs_to :user
  belongs_to :viewing_party
end