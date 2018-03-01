class CreateAds < ActiveRecord::Migration[5.1]
  def change
    create_table :ads do |t|
      t.integer :ad_group_id, limit: 8
      t.string :headline_part1
      t.string :headline_part2
      t.string :description
      t.string :final_urls
      t.string :path1
      t.string :path2

      t.timestamps
    end
  end
end
