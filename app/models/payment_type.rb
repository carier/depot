class PaymentType < ActiveRecord::Base

private

  def self.get_payment_names
    find(:all).map{|item| item.name}
  end

  def self.get_payment_types
    find(:all).map{|item| [item.title, item.name]}
  end
  
end
