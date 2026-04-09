class CreateCharges < ActiveRecord::Migration[7.2]
  def change
    create_table :charges do |t|
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :amount,              null: false  # 課金額（円）
      t.string  :stripe_charge_id
      t.string  :stripe_transfer_id
      t.integer :status,              null: false, default: 0  # enum
      t.string  :donation_destination

      t.timestamps
    end

    add_index :charges, :stripe_charge_id
  end
end
