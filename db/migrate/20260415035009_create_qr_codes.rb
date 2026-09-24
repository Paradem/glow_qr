class CreateQrCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_codes do |t|
      t.string :url, null: false, limit: 2048
      t.integer :template, null: false, default: 1
      t.json :customizations
      t.string :short_code, null: false, limit: 20
      t.string :image_path, limit: 255
      t.timestamps
    end

    add_index :qr_codes, :short_code, unique: true
  end
end
