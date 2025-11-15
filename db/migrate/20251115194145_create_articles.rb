class CreateArticles < ActiveRecord::Migration[8.0]
  def up
    create_table :articles do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.boolean :published, default: false, null: false
      t.datetime :published_at
      t.string :category
      t.text :tags

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :published
    add_index :articles, :category
 end
  def down
    drop_table :articles
  end
end