class Order < ActiveRecord::Base
  has_many :line_items
  
  def self.get_payment_names
    PaymentType.find(:all).map{|item| item.name}
  end

  PAYMENT_TYPES = [
    # Displayed  stored in db
    [ "Check" ,       "check" ],
    [ "Credit card" ,    "cc" ],
    [ "Purchase order" , "po" ]
  ]
  
  validates_presence_of :name, :address, :email, :pay_type
  validates_inclusion_of :pay_type, :in => get_payment_names

  def add_line_items_from_cart(cart)
    cart.items.each do |item|
      li = LineItem.from_cart_item(item)
      line_items << li
    end
  end

private

  def self.get_payment_types
    PaymentType.find(:all).map{|item| [item.title, item.name]}
  end

end
