class Charge < ApplicationRecord
  belongs_to :task
  belongs_to :user

  # ステータス管理
  enum :status, { charge_pending: 0, succeeded: 1, charge_failed: 2 }

  # バリデーション
  validates :amount, presence: true, numericality: { greater_than: 0 }

  # スコープ
  scope :recent, -> { order(created_at: :desc) }
end
