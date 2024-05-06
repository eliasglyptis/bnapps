class CreateMeetings < ActiveRecord::Migration[7.1]
  def change
    create_table :meetings do |t|
      t.string :topic
      t.string :password
      t.string :image
      t.text :description
      t.datetime :start_time
      t.integer :duration
      t.integer :zoom_id
      t.integer :price

      t.timestamps
    end
  end
end
