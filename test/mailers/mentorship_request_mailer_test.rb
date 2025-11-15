require "test_helper"

class MentorshipRequestMailerTest < ActionMailer::TestCase
  test "new_request" do
    mail = MentorshipRequestMailer.new_request
    assert_equal "New request", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "request_accepted" do
    mail = MentorshipRequestMailer.request_accepted
    assert_equal "Request accepted", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "request_rejected" do
    mail = MentorshipRequestMailer.request_rejected
    assert_equal "Request rejected", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
