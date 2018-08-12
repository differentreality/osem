class CreateSponsorShipments < ActiveRecord::Migration[5.0]
  def change
    create_table :sponsor_shipments do |t|
      t.references :sponsor
      t.string :carrier
      t.string :track_no
      t.integer :boxes
      t.datetime :dispatched_at
      t.boolean :delivered
      t.boolean :available

      t.timestamps
    end
  end
end
