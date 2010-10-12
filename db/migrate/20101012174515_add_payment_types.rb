class AddPaymentTypes < ActiveRecord::Migration
  def self.up
    PaymentType.delete_all

    PaymentType.create(:title => 'Check', :name => 'check')
    PaymentType.create(:title => 'Credit card', :name => 'cc')
    PaymentType.create(:title => 'Purchase order', :name => 'po')
  end

  def self.down
    PaymentType.delete_all
  end
end
