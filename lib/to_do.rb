class To_do < ActiveRecord::Base.extend(Textacular)
  has_many :notes, as: :notable
end
