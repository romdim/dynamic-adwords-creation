require 'test_helper'

class AdGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ad_group = ad_groups(:one)
  end

  test "should get index" do
    get ad_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_ad_group_url
    assert_response :success
  end

  test "should create ad_group" do
    assert_difference('AdGroup.count') do
      post ad_groups_url, params: { ad_group: { campaign_id: @ad_group.campaign_id, campaign_name: @ad_group.campaign_name, id: @ad_group.id, micro_amount: @ad_group.micro_amount, name: @ad_group.name, status: @ad_group.status, xsi_type: @ad_group.xsi_type } }
    end

    assert_redirected_to ad_group_url(AdGroup.last)
  end

  test "should show ad_group" do
    get ad_group_url(@ad_group)
    assert_response :success
  end

  test "should get edit" do
    get edit_ad_group_url(@ad_group)
    assert_response :success
  end

  test "should update ad_group" do
    patch ad_group_url(@ad_group), params: { ad_group: { campaign_id: @ad_group.campaign_id, campaign_name: @ad_group.campaign_name, id: @ad_group.id, micro_amount: @ad_group.micro_amount, name: @ad_group.name, status: @ad_group.status, xsi_type: @ad_group.xsi_type } }
    assert_redirected_to ad_group_url(@ad_group)
  end

  test "should destroy ad_group" do
    assert_difference('AdGroup.count', -1) do
      delete ad_group_url(@ad_group)
    end

    assert_redirected_to ad_groups_url
  end
end
