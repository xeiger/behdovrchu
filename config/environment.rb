# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => 'apikey',
  :password => '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',
  :domain => 'heroku.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}