class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :description
      t.integer :notable_id
      t.string :notable_type
      t.timestamps
    end
  end
end
