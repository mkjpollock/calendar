class Note < ActiveRecord::Base.extend(Textacular)
  belongs_to :notable, polymorphic: true
end
