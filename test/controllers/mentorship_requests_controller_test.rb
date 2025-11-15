require "test_helper"

class MentorshipRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mentorship_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get mentorship_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get mentorship_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get mentorship_requests_create_url
    assert_response :success
  end

  test "should get edit" do
    get mentorship_requests_edit_url
    assert_response :success
  end

  test "should get update" do
    get mentorship_requests_update_url
    assert_response :success
  end
end
