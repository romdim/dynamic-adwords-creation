class CreateAdGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :ad_groups, { id: false } do |t|
      t.integer :id, limit: 8
      t.integer :campaign_id
      t.string :name
      t.string :campaign_name
      t.string :status
      t.string :xsi_type
      t.float :micro_amount

      t.timestamps
    end
  end
end
