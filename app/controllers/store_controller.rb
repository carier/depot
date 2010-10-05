class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    @cart = find_cart
    @counter = get_counter
  end

  def add_to_cart
    product = Product.find(params[:id])
    @cart = find_cart
    @current_item = @cart.add_product(product)
    session[:counter] = nil
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end

  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}" )
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index("Invalid product" )}
    end
  end

  def empty_cart
    session[:cart] = nil
    @cart = find_cart
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  end

private
  def find_cart
    session[:cart] ||= Cart.new
  end

  def get_counter
    if session[:counter].nil?
      session[:counter] = 0
    end
    session[:counter] += 1
  end

  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end

end
