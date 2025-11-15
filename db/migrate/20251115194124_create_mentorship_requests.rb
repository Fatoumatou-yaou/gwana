class CreateMentorshipRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :mentorship_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :mentor, null: false, foreign_key: { to_table: :users }
      t.text :message
      t.text :objectives
      t.string :desired_duration
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :mentorship_requests, :requester_id
    add_index :mentorship_requests, :mentor_id
    add_index :mentorship_requests, :status
  end
end
