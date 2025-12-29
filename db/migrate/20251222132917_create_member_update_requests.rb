class CreateMemberUpdateRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :member_update_requests do |t|
      t.references :member, null: false, foreign_key: true
      t.text :bio
      t.integer :status, default: 0, null: false
      t.references :reviewed_by, null: true, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :member_update_requests, :status
  end
end
