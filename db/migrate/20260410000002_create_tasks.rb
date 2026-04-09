class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true

      t.string   :title,          null: false
      t.text     :description
      t.integer  :penalty_amount  # 100-5000円（100円刻み）
      t.integer  :priority,       null: false, default: 3  # 1-5
      t.integer  :status,         null: false, default: 0  # enum
      t.date     :start_date
      t.date     :due_date,       null: false
      t.datetime :completed_at
      t.boolean  :charged,        default: false

      t.timestamps
    end

    add_index :tasks, [:user_id, :status]
    add_index :tasks, [:user_id, :due_date]
    add_index :tasks, [:user_id, :penalty_amount]
    add_index :tasks, [:due_date, :status, :charged]
  end
end
