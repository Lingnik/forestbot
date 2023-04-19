# app/mailers/application_mailer.rb
# frozen_string_literal: true

# ApplicationMailer is the base class for all mailers in your application.
# It sets some default values for the mailer, and allows you to define
# helper methods that can be used in all mailers.
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
