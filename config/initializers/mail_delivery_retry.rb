require "net/smtp"
require "openssl"

# E-maily se posílají na pozadí (viz Entrant#send_email). Při dočasné chybě
# SMTP serveru Gmailu se odeslání zopakuje, místo aby e-mail propadl.
Rails.application.config.after_initialize do
  ActionMailer::MailDeliveryJob.retry_on(
    Net::SMTPServerBusy, Net::SMTPUnknownError, Net::OpenTimeout, Net::ReadTimeout,
    Errno::ECONNRESET, Errno::ECONNREFUSED, SocketError, OpenSSL::SSL::SSLError,
    wait: 1.minute, attempts: 5
  )
end
