require 'test_helper'

class SynchronizeControllerTest < ActionDispatch::IntegrationTest
  test "should get workpage" do
    get synchronize_workpage_url
    assert_response :success
  end

end
