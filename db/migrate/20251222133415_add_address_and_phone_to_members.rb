class AddAddressAndPhoneToMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :members, :address, :string
    add_column :members, :phone, :string
  end
end
