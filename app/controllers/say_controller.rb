class SayController < ApplicationController
  def hello
  end
  def navigation
    @files = Dir.glob('*')
  end
end
