require 'facebook_ads'

class CampaignsController < ApplicationController

  PAGE_SIZE = 50

  def index()
    @selected_account = selected_account

    ad_account = FacebookAds::AdAccount.get 'act_'+ENV['ACCOUNT_ID'], 'name'
    @fb_campaigns = ad_account.campaigns(fields: 'name, status').all

    if @selected_account
      response = request_campaigns_list()
      if response
        @campaigns = Campaigns.get_campaigns_list(response)
        @campaign_count = response[:total_num_entries]
      end
    end
  end

  def new
    @campaign = Campaigns.new({id: nil, name: nil, status: nil})
  end

  # POST /campaigns
  def create
    @ad_account = FacebookAds::AdAccount.get 'act_'+ENV['ACCOUNT_ID'], 'name'
    pp params
    @ad_account.campaigns.create({
                                    name: params[:campaign][:name],
                                    objective: 'CONVERSIONS',
                                    status: params[:campaign][:status],
                                })
    redirect_to campaigns_path
  end

  # DELETE /campaigns/1
  def destroy
    FacebookAds::Campaign.get(params[:campaign_id]).delete
    redirect_to campaigns_url, notice: "Campaign #{params[:id]} was successfully destroyed."
  end

  private

  def request_campaigns_list()
    api = get_adwords_api()
    service = api.service(:CampaignService, get_api_version())
    selector = {
      :fields => ['Id', 'Name', 'Status'],
      :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
      :paging => {:start_index => 0, :number_results => PAGE_SIZE}
    }
    result = nil
    begin
      result = service.get(selector)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    return result
  end
end
