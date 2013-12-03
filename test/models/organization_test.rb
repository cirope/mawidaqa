require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
    @organization = Fabricate(:organization)
  end

  test 'create' do
    assert_difference ['Organization.count', 'PaperTrail::Version.count'] do
      @organization = Organization.create(Fabricate.attributes_for(:organization))
    end

    assert @organization.xml_reference.present?
  end

  test 'update' do
    assert_difference 'PaperTrail::Version.count' do
      assert_no_difference 'Organization.count' do
        assert @organization.update_attributes(name: 'Updated')
      end
    end

    assert_equal 'Updated', @organization.reload.name
  end

  test 'destroy' do
    assert_difference 'PaperTrail::Version.count' do
      assert_difference('Organization.count', -1) { @organization.destroy }
    end
  end

  test 'validates blank attributes' do
    @organization.name = ''
    @organization.identification = ''

    assert @organization.invalid?
    assert_equal 2, @organization.errors.size
    assert_equal [error_message_from_model(@organization, :name, :blank)],
      @organization.errors[:name]
    assert_equal [error_message_from_model(@organization, :identification, :blank)],
      @organization.errors[:identification]
  end

  test 'validates unique attributes' do
    @organization.identification = Fabricate(:organization).identification

    assert @organization.invalid?
    assert_equal 1, @organization.errors.size
    assert_equal [error_message_from_model(@organization, :identification, :taken)],
      @organization.errors[:identification]
  end

  test 'validates attributes are well formated' do
    @organization.identification = 'xyz_'

    assert @organization.invalid?
    assert_equal 1, @organization.errors.size
    assert_equal [error_message_from_model(@organization, :identification, :invalid)],
      @organization.errors[:identification]

    @organization.identification = 'xyz-'

    assert @organization.invalid?
    assert_equal 1, @organization.errors.size
    assert_equal [error_message_from_model(@organization, :identification, :invalid)],
      @organization.errors[:identification]
  end

  test 'validates excluded attributes' do
    @organization.identification = RESERVED_SUBDOMAINS.first

    assert @organization.invalid?
    assert_equal 1, @organization.errors.size
    assert_equal [
      error_message_from_model(@organization, :identification, :exclusion)
    ], @organization.errors[:identification]
  end

  test 'validates length of _long_ attributes' do
    @organization.name = 'abcde' * 52
    @organization.identification = 'abcde' * 52

    assert @organization.invalid?
    assert_equal 2, @organization.errors.count
    assert_equal [
      error_message_from_model(@organization, :name, :too_long, count: 255)
    ], @organization.errors[:name]
    assert_equal [
      error_message_from_model(@organization, :identification, :too_long, count: 255)
    ], @organization.errors[:identification]
  end

  test 'magick search' do
    5.times { Fabricate(:organization, name: 'magick_name') }
    3.times do
      Fabricate(:organization) do
        identification {
          "magick-identification-#{sequence(:organization_identification)}"
        }
      end
    end

    Fabricate(
      :organization, name: 'magick_name', identification: 'magick-identification-10'
    )

    organizations = Organization.magick_search('magick')

    assert_equal 9, organizations.count
    assert organizations.all? { |s| s.inspect =~ /magick/ }

    organizations = Organization.magick_search('magick_name')

    assert_equal 6, organizations.count
    assert organizations.all? { |s| s.inspect =~ /magick_name/ }

    organizations = Organization.magick_search('magick_name magick-identification')

    assert_equal 1, organizations.count
    assert organizations.all? { |s| s.inspect =~ /magick-identification.*magick_name/ }

    organizations = Organization.magick_search(
      "magick_name #{I18n.t('magick_columns.or').first} magick-identification"
    )

    assert_equal 9, organizations.count
    assert organizations.all? { |s| s.inspect =~ /magick_name|magick-identification/ }

    organizations = Organization.magick_search('noorganization')

    assert organizations.empty?
  end
end
