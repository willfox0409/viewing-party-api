class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :viewing_party, null: false, foreign_key: true
      t.boolean :host

      t.timestamps
    end
  end
end
