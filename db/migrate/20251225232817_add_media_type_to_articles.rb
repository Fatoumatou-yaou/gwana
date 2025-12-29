class AddMediaTypeToArticles < ActiveRecord::Migration[8.0]
  def change
    # La colonne media_type a déjà été ajoutée par la migration AddMediaToArticles
    # Cette migration ne fait rien car la colonne existe déjà
    # Si vous avez besoin d'un index, ajoutez-le dans une migration séparée
  end
end
