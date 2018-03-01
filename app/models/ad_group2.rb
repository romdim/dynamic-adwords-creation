class AdGroup2
  attr_reader :id
  attr_reader :campaign_id
  attr_reader :campaign_name
  attr_reader :name
  attr_reader :status
  attr_reader :xsi_type
  attr_reader :micro_amount

  def initialize(ad_group)
    @id = ad_group[:id]
    @name = ad_group[:name]
    @status = ad_group[:status]
    @xsi_type = ad_group[:xsi_type]
    @micro_amount = ad_group[:micro_amount]
  end

  def self.get_campaigns_list(response)
    result = {}
    if response[:entries]
      response[:entries].each do |api_campaign|
        campaign = AdGroup.new(api_campaign)
        result[campaign.id] = campaign
      end
    end
    return result
  end
end
