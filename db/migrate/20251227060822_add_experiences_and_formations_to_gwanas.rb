class AddExperiencesAndFormationsToGwanas < ActiveRecord::Migration[8.0]
  def change
    add_column :gwanas, :experiences, :text
    add_column :gwanas, :formations, :text
  end
end
