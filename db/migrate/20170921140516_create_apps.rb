class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.string :url
      t.string :status

      t.timestamps
    end
  end
end
