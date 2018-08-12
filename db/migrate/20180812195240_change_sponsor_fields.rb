class ChangeSponsorFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :sponsors, :swag_delivered
    remove_column :sponsors, :swag_available
    remove_column :sponsors, :swag
    remove_column :sponsors, :shipments
    add_column :sponsors, :notes, :text
  end
end
