class Notifier < ActionMailer::Base
  layout 'notifier_mailer'
  helper :application
  default from: "'#{I18n.t('app_name')}' <#{APP_CONFIG['support_email']}>"
end
