class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :url, index: { unique: true, name: 'unique_image_url' }
      t.string :format
      t.blob :bin
      t.timestamps
    end
  end
end
