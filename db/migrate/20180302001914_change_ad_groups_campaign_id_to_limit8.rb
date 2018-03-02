class ChangeAdGroupsCampaignIdToLimit8 < ActiveRecord::Migration[5.1]
  def change
    change_column :ad_groups, :campaign_id, :integer, limit: 8
  end
end
