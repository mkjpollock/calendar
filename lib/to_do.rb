class To_do < ActiveRecord::Base
  has_many :notes, as: :notable
end
