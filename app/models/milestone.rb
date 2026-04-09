class Milestone < ApplicationRecord
  belongs_to :task

  # バリデーション
  validates :title, presence: true

  # 並び順
  default_scope { order(position: :asc) }

  # 完了トグル
  def toggle_complete!
    if completed?
      update!(completed: false, completed_at: nil)
    else
      update!(completed: true, completed_at: Time.current)
    end
  end

  def completed?
    completed
  end
end
