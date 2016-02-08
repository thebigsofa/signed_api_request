require 'test_helper'
require 'signed_api_request'
require 'pry'

class SignedApiRequestTest < Minitest::Test
  def setup
    SignedApiRequest.configure do |config|
      config.secret = 'secret'
      config.key_id = 'key_id'
    end
  end

  def test_is_configurable
    assert_equal 'secret', SignedApiRequest.encoder.secret
    assert_equal 'key_id', SignedApiRequest.encoder.key_id
  end

  def test_generate
    expires = Time.at(1_439_888_470 + 3600).utc
    encoded = SignedApiRequest.generate(guids: %w(guid1 guid2 guid3), expires: expires)
    assert_equal 'QzismnWSyZLbPMKWu9LC8HPpG1yL%2FtaFHVcT72uuAao%3D', encoded
  end

  def test_validate_succeeds
    time = Time.at(1_439_888_470).utc # "2015-08-18 09:01:10 UTC"

    Timecop.freeze(time - 3600) do
      validation_result = SignedApiRequest.validate(
        key_id: 'key_id',
        secret: 'secret',
        guids: %w(guid1 guid2 guid3),
        expires: (time + 3600).to_i,
        signature: 'QzismnWSyZLbPMKWu9LC8HPpG1yL/taFHVcT72uuAao=',
      )

      assert_equal true, validation_result
    end
  end

  def test_validate_fails_if_time_is_in_the_past_or_present
    time = Time.at(1_439_888_470).utc # "2015-08-18 09:01:10 UTC"

    Timecop.freeze(time + 3600) do
      validation_result = SignedApiRequest.validate(
        key_id: 'key_id',
        secret: 'secret',
        guids: %w(guid1 guid2 guid3),
        expires: (time + 3600).to_i,
        signature: 'QzismnWSyZLbPMKWu9LC8HPpG1yL/taFHVcT72uuAao='
      )

      assert_equal false, validation_result
    end
  end

  def test_validate_fails_if_time_is_manipulated
    time = Time.at(1_439_888_470).utc # "2015-08-18 09:01:10 UTC"

    Timecop.freeze(time + 3600) do
      validation_result = SignedApiRequest.validate(
        key_id: 'key_id',
        secret: 'secret',
        guids: %w(guid1 guid2 guid3),
        expires: (time + 3600).to_i + 3600,
        signature: 'QzismnWSyZLbPMKWu9LC8HPpG1yL/taFHVcT72uuAao='
      )

      assert_equal false, validation_result
    end
  end

  def test_validate_fails_if_secret_is_invalid
    time = Time.at(1_439_888_470).utc # "2015-08-18 09:01:10 UTC"

    Timecop.freeze(time + 3600) do
      validation_result = SignedApiRequest.validate(
        key_id: 'key_id',
        secret: 'ibvalid_secret',
        guids: %w(guid1 guid2 guid3),
        expires: (time + 3600).to_i,
        signature: 'QzismnWSyZLbPMKWu9LC8HPpG1yL/taFHVcT72uuAao='
      )

      assert_equal false, validation_result
    end
  end

  def test_validate_fails_if_key_id_is_invalid
    time = Time.at(1_439_888_470).utc # "2015-08-18 09:01:10 UTC"

    Timecop.freeze(time + 3600) do
      validation_result = SignedApiRequest.validate(
        key_id: 'invalid_key_id',
        secret: 'secret',
        guids: %w(guid1 guid2 guid3),
        expires: (time + 3600).to_i,
        signature: 'QzismnWSyZLbPMKWu9LC8HPpG1yL/taFHVcT72uuAao='
      )

      assert_equal false, validation_result
    end
  end
end
