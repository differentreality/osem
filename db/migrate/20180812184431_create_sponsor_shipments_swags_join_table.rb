class CreateSponsorShipmentsSwagsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :sponsor_shipments, :sponsor_swags
  end
end
