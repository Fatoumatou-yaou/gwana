class AddActivityDateToGwanaActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :gwana_activities, :activity_date, :date
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE gwana_activities SET activity_date = created_at::date WHERE activity_date IS NULL
        SQL
        change_column_null :gwana_activities, :activity_date, false
      end
    end
  end

  def down
    remove_column :gwana_activities, :activity_date
  end
end
