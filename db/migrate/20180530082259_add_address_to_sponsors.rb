class AddAddressToSponsors < ActiveRecord::Migration[5.0]
  def change
    add_column :sponsors, :address, :text
  end
end
