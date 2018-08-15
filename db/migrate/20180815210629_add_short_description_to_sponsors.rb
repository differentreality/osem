class AddShortDescriptionToSponsors < ActiveRecord::Migration[5.0]
  def change
    add_column :sponsors, :short_description, :text
  end
end
