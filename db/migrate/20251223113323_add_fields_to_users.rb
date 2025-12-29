class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :country_code, :string
    add_column :users, :profile, :integer, default: 0, null: false
    add_column :users, :is_verified, :boolean, default: false, null: false
    add_column :users, :otp, :string
    add_column :users, :otp_sent_at, :datetime
    add_column :users, :deleted_at, :datetime

    add_index :users, :phone
    add_index :users, :profile
    add_index :users, :is_verified
    add_index :users, :deleted_at
  end
end
