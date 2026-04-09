class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400
      return
    end

    case event.type
    when "payment_intent.succeeded"
      handle_payment_success(event.data.object)
    when "payment_intent.payment_failed"
      handle_payment_failure(event.data.object)
    end

    render json: { received: true }, status: 200
  end

  private

  def handle_payment_success(payment_intent)
    charge = Charge.find_by(stripe_charge_id: payment_intent.id)
    charge&.update!(status: :succeeded)
  end

  def handle_payment_failure(payment_intent)
    charge = Charge.find_by(stripe_charge_id: payment_intent.id)
    charge&.update!(status: :charge_failed)
  end
end
