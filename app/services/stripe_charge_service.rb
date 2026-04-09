class StripeChargeService
  DONATION_ACCOUNT = ENV["STRIPE_DONATION_ACCOUNT_ID"]

  def charge_for_task(task)
    user = task.user
    return unless user.card_registered?

    # PaymentIntent を作成（ユーザーのカードから課金）
    payment_intent_params = {
      amount: task.penalty_amount,
      currency: "jpy",
      customer: user.stripe_customer_id,
      confirm: true,
      automatic_payment_methods: {
        enabled: true,
        allow_redirects: "never"
      },
      metadata: {
        task_id: task.id,
        user_id: user.id,
        task_title: task.title
      }
    }

    # 募金先アカウントが設定されている場合は Transfer を追加
    if DONATION_ACCOUNT.present? && DONATION_ACCOUNT != "acct_dummy_donation"
      payment_intent_params[:transfer_data] = { destination: DONATION_ACCOUNT }
    end

    payment_intent = Stripe::PaymentIntent.create(payment_intent_params)

    # Charge レコードを作成
    charge = Charge.create!(
      task: task,
      user: user,
      amount: task.penalty_amount,
      stripe_charge_id: payment_intent.id,
      status: payment_intent.status == "succeeded" ? :succeeded : :charge_pending,
      donation_destination: "募金先団体"
    )

    # タスクのステータスを更新
    task.update!(status: :charged, charged: true)

    charge
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe課金エラー (Task ##{task.id}): #{e.message}"

    Charge.create!(
      task: task,
      user: user,
      amount: task.penalty_amount,
      stripe_charge_id: nil,
      status: :charge_failed,
      donation_destination: "募金先団体"
    )

    task.update!(status: :failed)
    nil
  end
end
