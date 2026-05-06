class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :event,   null: false, foreign_key: true
      t.references :invitee, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :invitations, [ :event_id, :invitee_id ], unique: true
  end
end
