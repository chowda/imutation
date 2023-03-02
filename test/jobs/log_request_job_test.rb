require "test_helper"

class LogRequestJobTest < ActiveSupport::TestCase
  test "logs request successfully" do
    params = {url: 'test', host: 'test', referer: nil}
    assert_difference 'Log.count', 1 do
      LogRequestJob.perform_now(params)
    end
  end

  test "log fails on bad params" do
    params = {url: 'test', bad: 'boo'}
    assert_raises {
      LogRequestJob.perform_now(params)
    }
  end
end
