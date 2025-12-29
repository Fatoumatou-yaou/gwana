class AddCommuneToMembers < ActiveRecord::Migration[8.0]
  def change
    add_reference :members, :commune, null: true, foreign_key: true, index: true
  end
end
