class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.text :bio
      t.string :profession
      t.text :skills
      t.string :region
      t.boolean :available_for_mentorship, default: false, null: false
      t.string :linkedin_url
      t.string :twitter_url
      t.string :website_url
      t.string :slug

      t.timestamps
    end

    add_index :members, :slug, unique: true
    add_index :members, :user_id, unique: true
    add_index :members, :region
    add_index :members, :available_for_mentorship
  end
end
