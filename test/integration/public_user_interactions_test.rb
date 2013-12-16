require 'test_helper'

class PublicUserInteractionsTest < ActionDispatch::IntegrationTest
  test 'should ask for login' do
    visit new_user_path

    assert_equal new_user_session_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert')
  end

  test 'should send reset password instructions' do
    user = Fabricate(:user)

    visit new_user_session_path

    assert_page_has_no_errors!

    click_link I18n.t('sessions.new.forgot_password')

    sleep 0.5

    assert_equal new_user_password_path, current_path
    assert_page_has_no_errors!

    fill_in 'user_email', with: user.email

    assert_difference 'ActionMailer::Base.deliveries.size' do
      find('.btn-default').click
    end

    assert_equal new_user_session_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert.alert-info')

    within '.alert.alert-info' do
      assert page.has_content?(I18n.t('devise.passwords.send_instructions'))
    end
  end

  test 'should be able to login and logout' do
    login

    within '.navbar-collapse .navbar-right' do
      find('a.dropdown-toggle').click
      click_link I18n.t('navigation.logout')
    end

    assert_equal new_user_session_path, current_path

    assert_page_has_no_errors!
    assert page.has_css?('.alert.alert-info')

    within '.alert.alert-info' do
      assert page.has_content?(I18n.t('devise.sessions.signed_out'))
    end
  end
end
