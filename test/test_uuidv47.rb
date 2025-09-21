# frozen_string_literal: true

require 'test_helper'

class TestUuidv47 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Uuidv47::VERSION
  end

  def test_uuid_parse_and_format_roundtrip
    str = '00000000-0000-7000-8000-000000000000'
    uuid = Uuidv47::UUID.new(str)
    assert_equal 7, uuid.version

    formatted = uuid.to_s
    uuid2 = Uuidv47::UUID.new(formatted)
    assert_equal uuid.bytes, uuid2.bytes
  end

  def test_version_and_variant_setting
    uuid = Uuidv47::UUID.new('00000000-0000-0000-0000-000000000000')
    uuid.set_version(7)
    assert_equal 7, uuid.version

    uuid.set_variant_rfc4122
    assert_equal 0x80, uuid.bytes[8].ord & 0xC0
  end

  def test_encode_decode_roundtrip
    v7_str = '01921e83-7c3a-7000-8000-000000000001'
    v7 = Uuidv47::UUID.new(v7_str)

    key = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)

    v4_facade = v7.encode_v4facade(key)
    assert_equal 4, v4_facade.version

    v7_decoded = Uuidv47::UUID.decode_v4facade(v4_facade, key)
    assert_equal 7, v7_decoded.version
    assert_equal v7.bytes, v7_decoded.bytes
  end

  def test_key_generation
    key = Uuidv47::Key.new
    assert key.k0 > 0
    assert key.k1 > 0
  end

  def test_key_from_hex
    key = Uuidv47::Key.from_hex('0123456789abcdef:fedcba9876543210')
    assert_equal 0x0123456789abcdef, key.k0
    assert_equal 0xfedcba9876543210, key.k1

    hex = key.to_hex
    assert_equal '0123456789abcdef:fedcba9876543210', hex
  end

  def test_different_keys_produce_different_facades
    v7 = Uuidv47::UUID.new('01921e83-7c3a-7000-8000-000000000001')

    key1 = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)
    key2 = Uuidv47::Key.new(0xdeadbeefcafebabe, 0x1234567890abcdef)

    facade1 = v7.encode_v4facade(key1)
    facade2 = v7.encode_v4facade(key2)

    refute_equal facade1.bytes, facade2.bytes
  end

  def test_generate_v7
    uuid = Uuidv47::UUID.new
    assert_equal 7, uuid.version
    assert_equal 0x80, uuid.bytes[8].ord & 0xC0
  end

  def test_convenience_methods
    v7_str = '01921e83-7c3a-7000-8000-000000000001'
    key = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)

    v4 = Uuidv47.encode_v4facade(v7_str, key)
    assert_equal 4, v4.version

    v7_back = Uuidv47.decode_v4facade(v4, key)
    assert_equal 7, v7_back.version

    v7 = Uuidv47::UUID.new(v7_str)
    v4 = Uuidv47.encode_v4facade(v7, key)
    assert_equal 4, v4.version
  end
end
