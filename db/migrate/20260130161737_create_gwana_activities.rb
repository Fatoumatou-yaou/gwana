class CreateGwanaActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :gwana_activities do |t|
      t.references :gwana, null: false, foreign_key: true
      t.string :activity_type
      t.string :youtube_video_id
      t.text :description

      t.timestamps
    end
    
    add_index :gwana_activities, :activity_type
  end
end
