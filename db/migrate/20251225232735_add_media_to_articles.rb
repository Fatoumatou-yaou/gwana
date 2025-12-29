class AddMediaToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :media_type, :string
  end
end
