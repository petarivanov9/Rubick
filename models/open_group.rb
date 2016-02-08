require 'sinatra/activerecord'

class OpenGroup < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true, uniqueness: true

  has_many :user_open_groups
end
