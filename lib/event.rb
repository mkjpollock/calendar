class Event < ActiveRecord::Base.extend(Textacular)
  has_many :notes, as: :notable
  has_many :occurances
end
