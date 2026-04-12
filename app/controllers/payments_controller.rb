class PaymentsController < ApplicationController
  def index
    @charges = current_user.charges.recent.includes(:task)
    
    # Stripeからカード一覧を取得
    if current_user.stripe_customer_id.present?
      @payment_methods = Stripe::PaymentMethod.list(
        customer: current_user.stripe_customer_id,
        type: "card"
      )
      
      # 顧客情報を取得してデフォルトカードを確認
      customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      @default_payment_method_id = customer.invoice_settings.default_payment_method
    else
      @payment_methods = []
    end
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
    # カード登録完了（Stripe.js側で既に紐付け済み）
    current_user.update!(card_registered: true)
    
    # 最初の1枚なら自動的にデフォルトに設定する（Stripe側の仕様で自動になることもあるが明示的に）
    customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    if customer.invoice_settings.default_payment_method.nil?
      # 最新のPaymentMethodを取得してデフォルトに設定
      pms = Stripe::PaymentMethod.list(customer: current_user.stripe_customer_id, type: "card")
      if pms.data.any?
        Stripe::Customer.update(
          current_user.stripe_customer_id,
          invoice_settings: { default_payment_method: pms.data.first.id }
        )
      end
    end

    redirect_to payments_path, notice: "クレジットカードを登録しました"
  rescue => e
    redirect_to new_payment_path, alert: "カード登録に失敗しました: #{e.message}"
  end

  # メインカードに設定
  def make_default
    Stripe::Customer.update(
      current_user.stripe_customer_id,
      invoice_settings: { default_payment_method: params[:id] }
    )
    redirect_to payments_path, notice: "メインのカードを変更しました"
  rescue => e
    redirect_to payments_path, alert: "設定に失敗しました: #{e.message}"
  end

  # カードの削除
  def destroy_card
    # Stripeからカードを切り離す
    Stripe::PaymentMethod.detach(params[:id])
    
    # 残りのカードを確認
    pms = Stripe::PaymentMethod.list(customer: current_user.stripe_customer_id, type: "card")
    if pms.data.empty?
      current_user.update!(card_registered: false)
    elsif params[:id] == Stripe::Customer.retrieve(current_user.stripe_customer_id).invoice_settings.default_payment_method
      # 削除したのがデフォルトだったら、次のカードをデフォルトにする
      Stripe::Customer.update(
        current_user.stripe_customer_id,
        invoice_settings: { default_payment_method: pms.data.first.id }
      )
    end

    redirect_to payments_path, notice: "カードを削除しました"
  rescue => e
    redirect_to payments_path, alert: "削除に失敗しました: #{e.message}"
  end

  def card_status
    render json: { card_registered: current_user.card_registered? }
  end
end
