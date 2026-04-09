class Task < ApplicationRecord
  belongs_to :user
  has_many :milestones, dependent: :destroy
  has_many :charges, dependent: :destroy

  # ステータス管理
  enum :status, { pending: 0, in_progress: 1, completed: 2, failed: 3, charged: 4 }

  # バリデーション
  validates :title, presence: true
  validates :penalty_amount, inclusion: { in: (100..5000).step(100).to_a }, allow_nil: true
  validates :priority, inclusion: { in: 1..5 }
  validates :due_date, presence: true

  # スコープ（表示モード対応）
  scope :by_amount, -> { order(penalty_amount: :desc, created_at: :desc) }
  scope :by_created, -> { order(created_at: :desc) }
  scope :by_date, ->(date) { where(due_date: date).order(priority: :desc) }
  scope :by_month, ->(date) {
    where(due_date: date.beginning_of_month..date.end_of_month).order(due_date: :asc)
  }
  scope :active, -> { where.not(status: [:completed, :charged]) }
  scope :overdue_and_uncharged, -> {
    where("due_date < ? AND status != ? AND charged = ?", Date.current, statuses[:completed], false)
  }

  # マイルストーン進捗率
  def milestone_progress
    return 0 if milestones.empty?
    completed = milestones.where(completed: true).count
    (completed.to_f / milestones.count * 100).round
  end

  # 残り日数
  def days_remaining
    return nil unless due_date
    (due_date - Date.current).to_i
  end

  # 期限切れかどうか
  def overdue?
    due_date.present? && due_date < Date.current && !completed?
  end

  # タスクを完了する
  def mark_complete!
    update!(status: :completed, completed_at: Time.current)
  end
end
