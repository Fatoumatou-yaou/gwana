class CreateNetworkEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :network_events do |t|
      t.string :name
      t.text :description
      t.date :event_date

      t.timestamps
    end
  end
end
