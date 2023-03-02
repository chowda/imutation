require "test_helper"

class LogTest < ActiveSupport::TestCase
  test "empty log is valid" do
    assert_nothing_raised {
      Log.create()
    }
  end

  test "log creates with all data" do
    assert_difference 'Log.count', 1 do
      Log.create(url: "test", referer: "test", host: "test", requested_at: Time.now.utc)
    end
  end
end
