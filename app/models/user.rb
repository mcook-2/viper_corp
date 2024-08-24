class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { user: 0, admin: 1 }
  after_initialize :set_default_role, if: :new_record?
  has_many :carts
  after_create :create_cart

  private

  def set_default_role
    self.role ||= :user
  end

  def create_cart
    Cart.create(user: self)
  end
end
