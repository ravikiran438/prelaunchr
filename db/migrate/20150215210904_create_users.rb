class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :referral_code
      t.integer :referrer_id
      t.boolean :valid_email, default: false

      t.timestamps null: false
    end
  end
end
