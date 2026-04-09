class PaymentsController < ApplicationController
  def index
    @charges = current_user.charges.recent.includes(:task)
  end

  def new
    # Stripe SetupIntent を作成
    if current_user.stripe_customer_id.blank?
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: current_user.name,
        metadata: { user_id: current_user.id }
      )
      current_user.update!(stripe_customer_id: customer.id)
    end

    @setup_intent = Stripe::SetupIntent.create(
      customer: current_user.stripe_customer_id,
      payment_method_types: ["card"]
    )
    @client_secret = @setup_intent.client_secret
  end

  def create
    # カード登録完了
    current_user.update!(card_registered: true)
    redirect_to tasks_path, notice: "クレジットカードを登録しました"
  rescue => e
    redirect_to new_payment_path, alert: "カード登録に失敗しました: #{e.message}"
  end

  def card_status
    render json: { card_registered: current_user.card_registered? }
  end
end
