MawidaQA::Application.configure do
  config.action_mailer.default_url_options = {
    host: ['www', APP_CONFIG['public_host']].join('.')
  }
  config.action_mailer.smtp_settings = APP_CONFIG['smtp'].symbolize_keys
end
