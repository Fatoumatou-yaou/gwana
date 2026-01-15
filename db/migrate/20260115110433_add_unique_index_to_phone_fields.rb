class AddUniqueIndexToPhoneFields < ActiveRecord::Migration[8.0]
  def change
    add_index :gwana_network_requests, :phone, unique: true, where: "phone IS NOT NULL", name: "index_gwana_network_requests_on_phone_unique"
    
    add_index :gwanas, :phone, unique: true, where: "phone IS NOT NULL", name: "index_gwanas_on_phone_unique"
  end
end
