class CreateGwanaPortraitVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :gwana_portrait_videos do |t|
      t.references :gwana, null: false, foreign_key: true
      t.string :youtube_video_id
      t.text :teaser_text
      t.integer :display_order

      t.timestamps
    end
    
    add_index :gwana_portrait_videos, :display_order
  end
end
