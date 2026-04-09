class CreateMilestones < ActiveRecord::Migration[7.2]
  def change
    create_table :milestones do |t|
      t.references :task, null: false, foreign_key: true

      t.string   :title,        null: false
      t.boolean  :completed,    default: false
      t.date     :due_date
      t.integer  :position,     default: 0
      t.datetime :completed_at

      t.timestamps
    end

    add_index :milestones, [:task_id, :position]
  end
end
