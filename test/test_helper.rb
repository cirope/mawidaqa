ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'sidekiq/testing/inline'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  setup do
    instance_eval(File.read(Rails.root.join('test/lib/stub_requests.rb')))
  end

  def error_message_from_model(model, attribute, message, extra = {})
    ::ActiveModel::Errors.new(model).generate_message(attribute, message, extra)
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  setup do
    Capybara.default_driver = :selenium
    Capybara.server_port = '54163'
    Capybara.app_host = 'http://admin.lvh.me:54163'
    Capybara.default_wait_time = ENV['TRAVIS'] ? 4 : 2
  end

  teardown do
    # Truncate the database
    DatabaseCleaner.clean
    # Forget the (simulated) browser state
    Capybara.reset_sessions!
    # Revert Capybara.current_driver to Capybara.default_driver
    Capybara.use_default_driver
  end

  def login(options = {})
    clean_password = options[:clean_password] || '123456'
    user = options[:user] || Fabricate(:user, password: clean_password)
    expected_path = options[:expected_path]
    expected_path ||= user.is?(:admin) ? organizations_path : dashboard_path

    visit new_user_session_path

    assert_page_has_no_errors!

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: clean_password

    find('.btn-default').click

    assert page.has_css?('.navbar-collapse')
    assert_equal expected_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert.alert-info')

    within '.alert.alert-info' do
      assert page.has_content?(I18n.t('devise.sessions.signed_in'))
    end
  end

  def login_into_organization(options = {})
    organization = options[:organization] || Fabricate(:organization)
    Capybara.app_host = "http://#{organization.identification}.lvh.me:54163"

    user = options[:user] || Fabricate(:user, password: '123456', roles: [:normal])
      job = Fabricate(
        :job, user_id: user.id, organization_id: organization.id, job: options[:as] || 'author'
      )
      expected_path = url_for(
        controller: 'dashboard', action: job.job, only_path: true
      )

      login user: user, clean_password: '123456', expected_path: expected_path
  end

  def assert_page_has_no_errors!
    assert page.has_no_css?('#unexpected_error')
  end
end
