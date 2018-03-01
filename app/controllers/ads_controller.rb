class AdsController < ApplicationController
  before_action :set_account
  before_action :set_ad, only: [:show, :edit, :update, :destroy]

  # GET /ads
  def index
    @ads = Ad.where(ad_group_id: params[:id]).all
  end

  # GET /ads/1
  def show
  end

  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/1/edit
  def edit
  end

  # POST /ads
  def create
    if @selected_account
      response = add_expanded_text_ad ad_params
      @ad = Ad.new ad_params
      @ad.id = response.first[:id]
      @ad.ad_group_id = params[:id]

      if @ad.save
        redirect_to @ad, notice: 'Ad was successfully created.'
      else
        render :new
      end
    else
      render :new
    end
  end

  # PATCH/PUT /ads/1
  def update
    if @ad.update(ad_params)
      redirect_to @ad, notice: 'Ad was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /ads/1
  def destroy
    @ad.destroy
    redirect_to ads_url, notice: 'Ad was successfully destroyed.'
  end

  private
  def set_account
    @selected_account = selected_account
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ad
    @ad = Ad.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def ad_params
    params.require(:ad).permit(:headline_part1, :headline_part2, :description, :final_urls, :path1, :path2)
  end

  def add_expanded_text_ad(ad)
    api = get_adwords_api

    # To enable logging of SOAP requests, set the log_level value to 'DEBUG' in
    # the configuration file or provide your own logger:
    # adwords.logger = Logger.new('adwords_xml.log')

    ad_group_ad_srv = api.service :AdGroupAdService, get_api_version

    # Create text ads.
    # The 'xsi_type' field allows you to specify the xsi:type of the object
    # being created. It's only necessary when you must provide an explicit
    # type that the client library can't infer.
    expanded_text_ad = {
        :xsi_type => 'ExpandedTextAd',
        :headline_part1 => ad[:headline_part1],
        :headline_part2 => ad[:headline_part2],
        :description => ad[:description],
        :final_urls => [ad[:final_urls]],
        :path1 => ad[:path1],
        :path2 => ad[:path2]
    }

    ad_group_ad = {
        :ad_group_id => params[:id],
        :ad => expanded_text_ad,
        # Additional properties (non-required).
        :status => 'PAUSED'
    }

    operation = {
        :operator => 'ADD',
        :operand => ad_group_ad
    }
    # Add ads.
    response = ad_group_ad_srv.mutate([operation])

    begin
      if response and response[:value]
        response[:value].each do |ad_group_ad|
          puts ('New expanded text ad with id "%d" and headline "%s - %s" was ' +
              'added.') % [ad_group_ad[:ad][:id], ad_group_ad[:ad][:headline_part1],
                           ad_group_ad[:ad][:headline_part2]]
          pp ad_group_ad
        end
      else
        raise StandardError, 'No ads were added.'
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
