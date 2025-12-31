class CreateGwanaNetworkRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :gwana_network_requests do |t|
      # Informations personnelles
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :address
      t.bigint :commune_id
      
      # Informations professionnelles
      t.string :profession
      t.text :experiences
      t.text :formations
      t.text :bio
      
      # Réseaux sociaux
      t.string :linkedin_url
      t.string :twitter_url
      t.string :website_url
      
      # Statut et gestion admin
      t.integer :status, default: 0, null: false
      t.bigint :reviewed_by_id
      t.datetime :reviewed_at
      t.text :rejection_reason
      
      t.timestamps
    end
    
    add_index :gwana_network_requests, :status
    add_index :gwana_network_requests, :reviewed_by_id
    add_index :gwana_network_requests, :commune_id
    add_index :gwana_network_requests, :email
    add_index :gwana_network_requests, :created_at
  end
end
