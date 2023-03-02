class LogRequestJob < ActiveJob::Base
  queue = :default

  def perform(params)
    Log.create!(**params)
  end
end
