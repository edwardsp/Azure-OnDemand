require 'test_helper'

class AzhpcclustersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get azhpcclusters_index_url
    assert_response :success
  end

end
