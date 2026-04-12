class ChangeTaskDatesToDatetime < ActiveRecord::Migration[7.2]
  def change
    change_column :tasks, :start_date, :datetime
    change_column :tasks, :due_date, :datetime
    change_column :milestones, :due_date, :datetime
  end
end
