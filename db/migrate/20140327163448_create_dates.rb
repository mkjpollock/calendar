class CreateDates < ActiveRecord::Migration
  def change
    create_table :occurances do |t|
      t.datetime :start
      t.datetime :end
      t.integer :event_id
      t.timestamps
    end
  end
end
