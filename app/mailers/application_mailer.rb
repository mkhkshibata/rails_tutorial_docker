class ApplicationMailer < ActionMailer::Base
  default from: "user@domain.com"
  layout "mailer"
end
