class AddDonationDestinationToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :donation_destination, :string
  end
end
