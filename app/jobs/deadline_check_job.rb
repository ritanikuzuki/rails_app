class DeadlineCheckJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[DeadlineCheckJob] 期限切れタスクのチェックを開始..."

    overdue_tasks = Task.overdue_and_uncharged
                        .includes(:user)
                        .where(users: { card_registered: true })

    overdue_tasks.find_each do |task|
      next unless task.user.card_registered?
      next if task.penalty_amount.nil? || task.penalty_amount.zero?

      Rails.logger.info "[DeadlineCheckJob] 課金実行: Task ##{task.id} '#{task.title}' - ¥#{task.penalty_amount}"
      StripeChargeService.new.charge_for_task(task)
    end

    Rails.logger.info "[DeadlineCheckJob] 完了 - #{overdue_tasks.count}件のタスクを処理"
  end
end
