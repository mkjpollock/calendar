class Occurance < ActiveRecord::Base
  belongs_to :event
  validates_datetime :start
  validates_datetime :end
end
