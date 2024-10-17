# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => 'gmail.com',
  :user_name => ENV['GMAIL_USERNAME'],
  :password => ENV['GMAIL_PASSWORD'],
  :authentication => :plain,
  :enable_starttls_auto => true,
  :open_timeout => 5,
  :read_timeout => 5 
}
