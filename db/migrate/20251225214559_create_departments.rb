class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.references :region, null: false, foreign_key: true

      t.timestamps
    end

    add_index :departments, [:name, :region_id], unique: true
  end
end
