class AdGroupsController < ApplicationController
  before_action :set_account
  before_action :set_ad_group, only: [:show, :edit, :update, :destroy]

  # GET /ad_groups
  def index
    @ad_groups = AdGroup.all
  end

  # GET /ad_groups/1
  def show
  end

  # GET /ad_groups/new
  def new
    @ad_group = AdGroup.new
  end

  # GET /ad_groups/1/edit
  def edit
  end

  # POST /ad_groups
  def create
    if @selected_account
      response = add_ad_group ad_group_params
      @ad_group = AdGroup.new ad_group_params
      @ad_group.id = response.first[:id]
      @ad_group.campaign_name = response.first[:campaign_name]

      if @ad_group.save
        redirect_to @ad_group, notice: 'Ad group was successfully created.'
      else
        render :new
      end
    else
      render :new
    end
  end

  # PATCH/PUT /ad_groups/1
  def update
    if @ad_group.update(ad_group_params)
      redirect_to @ad_group, notice: 'Ad group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /ad_groups/1
  def destroy
    @ad_group.destroy
    redirect_to ad_groups_url, notice: 'Ad group was successfully destroyed.'
  end

  private
  def set_account
    @selected_account = selected_account
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ad_group
    @ad_group = AdGroup.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ad_group_params
    params.require(:ad_group).permit(:campaign_id, :name, :status, :xsi_type, :micro_amount)
  end


  def add_ad_group(ad_group)
    api = get_adwords_api

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    # adwords.logger = Logger.new('adwords_xml.log')

    ad_group_srv = api.service :AdGroupService, get_api_version

    ad_groups = [
        {
            :name => ad_group['name'],
            :status => ad_group['status'],
            :campaign_id => ad_group['campaign_id'],
            :bidding_strategy_configuration => {
                :bids => [
                    {
                        # The 'xsi_type' field allows you to specify the xsi:type of the
                        # object being created. It's only necessary when you must provide
                        # an explicit type that the client library can't infer.
                        :xsi_type => ad_group['xsi_type'],
                        :bid => {:micro_amount => (ad_group['micro_amount'].to_f * 1000000.00).to_i}
                    }
                ]
            }
        }
    ]

    # Prepare operations for adding ad groups.
    operations = ad_groups.map do |ad_group|
      {:operator => 'ADD', :operand => ad_group}
    end

    # Add ad groups.
    response = ad_group_srv.mutate(operations)

    begin
      if response and response[:value]
        response[:value].each do |ad_group|
          puts "Ad group ID %d was successfully added." % ad_group[:id]
          pp ad_group
        end
      else
        raise StandardError, 'No ad group was added'
      end

        # Authorization error.
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
               "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
               "to retrieve and store OAuth2 tokens."
      puts "See this wiki page for more details:\n\n  " +
               'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

        # HTTP errors.
    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

        # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
    end
  end
end
