require 'test_helper'

class UserStoreisTest < ActionController::IntegrationTest
  fixtures :products

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  # A user goes to the index page. They select a product, adding it to their
  # cart, and check out, filling in their details on the checkout form. When
  # they submit, an order is created containing their information, along with a
  # single line item corresponding to the product they added to their cart.
  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby_book)

    get "/store/index"
    assert_response :success
    assert_template "index"

    xml_http_request :put, "/store/add_to_cart" , :id => ruby_book.id
    assert_response :success

    cart = session[:cart]
    assert_equal 1, cart.items.size
    assert_equal ruby_book, cart.items[0].product

    post "/store/checkout"
    assert_response :success
    assert_template "checkout"

    post_via_redirect "/store/save_order" ,
      :order => { :name => "Dave Thomas" ,
        :address => "123 The Street" ,
        :email => "dave@pragprog.com" ,
        :pay_type => "check" }

    assert_response :success
    assert_template "index"
    assert_equal 0, session[:cart].items.size

    orders = Order.find(:all)
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Dave Thomas" , order.name
    assert_equal "123 The Street" , order.address
    assert_equal "dave@pragprog.com" , order.email
    assert_equal "check" , order.pay_type

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

  end

  DAVES_DETAILS = {
    :name => "Dave Thomas" ,
    :address => "123 The Street" ,
    :email => "dave@pragprog.com" ,
    :pay_type => "check"
  }

  def test_buying_a_product
    dave = regular_user
    dave.get "/store/index"
    dave.is_viewing "index"
    dave.buys_a @ruby_book
    dave.has_a_cart_containing @ruby_book
    dave.checks_out DAVES_DETAILS
    dave.is_viewing "index"
    check_for_order DAVES_DETAILS, @ruby_book
  end
  
  def test_two_people_buying
    dave = regular_user
    mike = regular_user
    dave.buys_a @ruby_book
    mike.buys_a @rails_book
    dave.has_a_cart_containing @ruby_book
    dave.checks_out DAVES_DETAILS
    mike.has_a_cart_containing @rails_book
    check_for_order DAVES_DETAILS, @ruby_book
    mike.checks_out MIKES_DETAILS
    check_for_order MIKES_DETAILS, @rails_book
  end

  def regular_user
    open_session do |user|
      def user.is_viewing(page)
        assert_response :success
        assert_template page
      end
      def user.buys_a(product)
        xml_http_request :put, "/store/add_to_cart" , :id => product.id
        assert_response :success
      end
      def user.has_a_cart_containing(*products)
        cart = session[:cart]
        assert_equal products.size, cart.items.size
        for item in cart.items
          assert products.include?(item.product)
        end
      end
      def user.checks_out(details)
        post "/store/checkout"
        assert_response :success
        assert_template "checkout"
        post_via_redirect "/store/save_order" ,
          :order => { :name => details[:name],
            :address => details[:address],
            :email => details[:email],
            :pay_type => details[:pay_type]
            }
        assert_response :success
        assert_template "index"
        assert_equal 0, session[:cart].items.size
      end
    end
  end

end
