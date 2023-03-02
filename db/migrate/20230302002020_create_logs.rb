class CreateLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :logs do |t|
      t.string :url
      t.string :referer
      t.string :host
      t.datetime :requested_at
    end
  end
end
