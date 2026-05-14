class CreatePageViews < ActiveRecord::Migration[8.0]
  def change
    create_table :page_views do |t|
      t.string :ip_address
      t.string :user_agent
      t.string :path
      t.string :referer
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :page_views, :ip_address
    add_index :page_views, :created_at
    add_index :page_views, [ :ip_address, :created_at ]
  end
end
