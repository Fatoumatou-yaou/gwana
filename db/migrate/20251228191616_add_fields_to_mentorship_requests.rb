class AddFieldsToMentorshipRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :mentorship_requests, :motivation, :text
    add_column :mentorship_requests, :commune_id, :bigint
    add_column :mentorship_requests, :niveau_etudes, :string
    add_column :mentorship_requests, :filiere, :string
  end
end
