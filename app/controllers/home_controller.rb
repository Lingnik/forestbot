# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :login]
  skip_before_action :authorize_google, only: [:index, :login]
  def index
  end

  def login
  end
end
