class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one  :payment_method, dependent: :destroy

  enum role: { user: 0, admin: 1 }
  after_initialize :set_default_role, if: :new_record?

  has_many :carts, dependent: :destroy
  after_create :create_cart

  pay_customer stripe_attributes: :stripe_attributes

  def stripe_attributes(pay_customer)
    {
      address:  {
        city:    pay_customer.owner.shipping_city,
        country: pay_customer.owner.shipping_country
      },
      metadata: {
        pay_customer_id: pay_customer.id,
        user_id:         id
      }
    }
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def create_cart
    Cart.create(user: self)
  end
end
