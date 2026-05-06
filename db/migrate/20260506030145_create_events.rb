class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string     :title, null: false
      t.text       :description
      t.datetime   :starts_at, null: false
      t.string     :location
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
