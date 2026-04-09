class User < ApplicationRecord
  # Devise モジュール
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # アソシエーション
  has_many :tasks, dependent: :destroy
  has_many :charges, dependent: :destroy

  # Google OAuth でユーザーを作成/検索
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  # カード登録済みかどうか
  def card_registered?
    stripe_customer_id.present? && card_registered
  end
end
