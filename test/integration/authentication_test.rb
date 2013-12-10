require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Fabricate(:organization)
  end

  test 'should be able to login and logout as admin' do
    login

    within '.navbar-collapse .navbar-right' do
      find('a.dropdown-toggle').click
      click_link I18n.t('navigation.logout')
    end

    assert_equal new_user_session_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert')
    assert page.has_content?(I18n.t('devise.sessions.signed_out'))
  end

  test 'should be able to login as related to organization' do
    assert_difference 'Login.count' do
      login_into_organization organization: @organization
    end
  end

  test 'should not be able to login as no related to organization' do
    Capybara.app_host = "http://#{@organization.identification}.lvh.me:54163"

    user = Fabricate(:user, password: '123456', roles: [:normal])

    assert_no_difference 'Login.count' do
      invalid_login user: user, clean_password: '123456'
    end
  end

  test 'should normal user be redirected to his own subdomain in admin page' do
    user = Fabricate(:user, password: '123456', roles: [:normal])

    job = Fabricate(:job, user_id: user.id, organization_id: @organization.id)

    expected_path = url_for(
      controller: 'dashboard', action: job.job, only_path: true
    )

    login user: user, clean_password: '123456', expected_path: expected_path

    assert_match /\Ahttp:\/\/#{@organization.identification}\./, current_url
  end

  test 'should normal user be redirected to launchpad in admin page' do
    user = Fabricate(:user, password: '123456', roles: [:normal])

    Fabricate(:job, user_id: user.id, organization_id: @organization.id)
    Fabricate(:job, user_id: user.id)

    login user: user, clean_password: '123456', expected_path: launchpad_path

    assert_match launchpad_path, current_path
  end


  private

  def invalid_login(options = {})
    clean_password = options[:clean_password] || '123456'
    user = options[:user] || Fabricate(:user, password: clean_password)

    visit new_user_session_path

    assert_page_has_no_errors!

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: clean_password

    find('.btn.btn-default').click

    assert_equal new_user_session_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert')
    assert page.has_content?(I18n.t('devise.failure.invalid'))
  end
end
