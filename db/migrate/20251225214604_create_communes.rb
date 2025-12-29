class CreateCommunes < ActiveRecord::Migration[8.0]
  def change
    create_table :communes do |t|
      t.string :name, null: false
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end

    add_index :communes, [:name, :department_id], unique: true
  end
end
