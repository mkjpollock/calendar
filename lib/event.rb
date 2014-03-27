class Event < ActiveRecord::Base
  has_many :notes, as: :notable
  has_many :occurances
end
