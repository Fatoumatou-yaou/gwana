class RenameMembersToGwanas < ActiveRecord::Migration[8.0]
  def up
    # Renommer la table members en gwanas
    rename_table :members, :gwanas

    # Renommer les index de gwanas (vérifier l'existence avant de renommer)
    # Note: Rails ne renomme pas automatiquement les index, donc on doit le faire manuellement
    if index_exists?(:gwanas, "index_members_on_available_for_mentorship")
      rename_index :gwanas, "index_members_on_available_for_mentorship", "index_gwanas_on_available_for_mentorship"
    end
    if index_exists?(:gwanas, "index_members_on_region")
      rename_index :gwanas, "index_members_on_region", "index_gwanas_on_region"
    end
    if index_exists?(:gwanas, "index_members_on_slug")
      rename_index :gwanas, "index_members_on_slug", "index_gwanas_on_slug"
    end
    if index_exists?(:gwanas, "index_members_on_user_id")
      rename_index :gwanas, "index_members_on_user_id", "index_gwanas_on_user_id"
    end
    # Vérifier si l'index commune_id existe (peut ne pas exister si ajouté après)
    if index_exists?(:gwanas, "index_members_on_commune_id")
      rename_index :gwanas, "index_members_on_commune_id", "index_gwanas_on_commune_id"
    end

    # Renommer la table member_update_requests en gwana_update_requests
    rename_table :member_update_requests, :gwana_update_requests

    # Renommer la foreign key dans gwana_update_requests
    rename_column :gwana_update_requests, :member_id, :gwana_id
    
    # Renommer les index de gwana_update_requests
    if index_exists?(:gwana_update_requests, "index_member_update_requests_on_member_id")
      rename_index :gwana_update_requests, "index_member_update_requests_on_member_id", "index_gwana_update_requests_on_gwana_id"
    end
    if index_exists?(:gwana_update_requests, "index_member_update_requests_on_reviewed_by_id")
      rename_index :gwana_update_requests, "index_member_update_requests_on_reviewed_by_id", "index_gwana_update_requests_on_reviewed_by_id"
    end
    if index_exists?(:gwana_update_requests, "index_member_update_requests_on_status")
      rename_index :gwana_update_requests, "index_member_update_requests_on_status", "index_gwana_update_requests_on_status"
    end

    # Mettre à jour les foreign keys
    remove_foreign_key :gwana_update_requests, :members if foreign_key_exists?(:gwana_update_requests, :members)
    remove_foreign_key :gwanas, :members if foreign_key_exists?(:gwanas, :members)
    
    # Ajouter les foreign keys uniquement si elles n'existent pas déjà
    add_foreign_key :gwana_update_requests, :gwanas, column: :gwana_id unless foreign_key_exists?(:gwana_update_requests, :gwanas, column: :gwana_id)
    add_foreign_key :gwanas, :users unless foreign_key_exists?(:gwanas, :users)
    add_foreign_key :gwanas, :communes unless foreign_key_exists?(:gwanas, :communes)
  end

  def down
    # Remettre les foreign keys
    remove_foreign_key :gwana_update_requests, :gwanas if foreign_key_exists?(:gwana_update_requests, :gwanas)
    remove_foreign_key :gwanas, :users if foreign_key_exists?(:gwanas, :users)
    remove_foreign_key :gwanas, :communes if foreign_key_exists?(:gwanas, :communes)

    add_foreign_key :member_update_requests, :members, column: :member_id if foreign_key_exists?(:member_update_requests, :members, column: :member_id) == false
    add_foreign_key :members, :users if foreign_key_exists?(:members, :users) == false

    # Renommer les index de gwana_update_requests (vérifier l'existence avant de renommer)
    if index_exists?(:gwana_update_requests, "index_gwana_update_requests_on_gwana_id")
      rename_index :gwana_update_requests, "index_gwana_update_requests_on_gwana_id", "index_member_update_requests_on_member_id"
    end
    if index_exists?(:gwana_update_requests, "index_gwana_update_requests_on_reviewed_by_id")
      rename_index :gwana_update_requests, "index_gwana_update_requests_on_reviewed_by_id", "index_member_update_requests_on_reviewed_by_id"
    end
    if index_exists?(:gwana_update_requests, "index_gwana_update_requests_on_status")
      rename_index :gwana_update_requests, "index_gwana_update_requests_on_status", "index_member_update_requests_on_status"
    end

    # Renommer la foreign key dans gwana_update_requests
    rename_column :gwana_update_requests, :gwana_id, :member_id

    # Renommer la table gwana_update_requests en member_update_requests
    rename_table :gwana_update_requests, :member_update_requests

    # Renommer les index de gwanas (vérifier l'existence avant de renommer)
    if index_exists?(:gwanas, "index_gwanas_on_available_for_mentorship")
      rename_index :gwanas, "index_gwanas_on_available_for_mentorship", "index_members_on_available_for_mentorship"
    end
    if index_exists?(:gwanas, "index_gwanas_on_region")
      rename_index :gwanas, "index_gwanas_on_region", "index_members_on_region"
    end
    if index_exists?(:gwanas, "index_gwanas_on_slug")
      rename_index :gwanas, "index_gwanas_on_slug", "index_members_on_slug"
    end
    if index_exists?(:gwanas, "index_gwanas_on_user_id")
      rename_index :gwanas, "index_gwanas_on_user_id", "index_members_on_user_id"
    end
    if index_exists?(:gwanas, "index_gwanas_on_commune_id")
      rename_index :gwanas, "index_gwanas_on_commune_id", "index_members_on_commune_id"
    end

    # Renommer la table gwanas en members
    rename_table :gwanas, :members
  end
end
