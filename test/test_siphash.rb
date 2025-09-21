# frozen_string_literal: true

require 'test_helper'

class TestSipHash < Minitest::Test
  def test_siphash_vectors
    k0 = 0x0706050403020100
    k1 = 0x0f0e0d0c0b0a0908

    test_vectors = {
      '' => 0x726fdb47dd0e0e31,
      "\x00" => 0x74f839c593dc67fd,
      "\x00\x01" => 0x0d6c8009d9a94f5a,
      "\x00\x01\x02" => 0x85676696d7fb7e2d,
      "\x00\x01\x02\x03" => 0xcf2794e0277187b7,
      "\x00\x01\x02\x03\x04" => 0x18765564cd99a68d,
      "\x00\x01\x02\x03\x04\x05" => 0xcbc9466e58fee3ce,
      "\x00\x01\x02\x03\x04\x05\x06" => 0xab0200f58b01d137,
      "\x00\x01\x02\x03\x04\x05\x06\x07" => 0x93f5f5799a932462,
      "\x00\x01\x02\x03\x04\x05\x06\x07\x08" => 0x9e0082df0ba9e4b0,
      "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09" => 0x7a5dbbc594ddb9f3,
      "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a" => 0xf4b32f46226bada7,
      "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b" => 0x751e8fbc860ee5fb
    }

    test_vectors.each do |input, expected|
      result = Uuidv47::SipHash.siphash24(input, k0, k1)
      assert_equal expected, result, "SipHash failed for input length #{input.length}"
    end
  end

  def test_siphash_with_longer_input
    k0 = 0x0123456789abcdef
    k1 = 0xfedcba9876543210

    input = "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a"
    result1 = Uuidv47::SipHash.siphash24(input, k0, k1)
    result2 = Uuidv47::SipHash.siphash24(input, k0, k1)

    assert_equal result1, result2
  end

  def test_siphash_different_keys_produce_different_results
    input = 'test message'

    k0_1 = 0x0123456789abcdef
    k1_1 = 0xfedcba9876543210

    k0_2 = 0xdeadbeefcafebabe
    k1_2 = 0x1234567890abcdef

    result1 = Uuidv47::SipHash.siphash24(input, k0_1, k1_1)
    result2 = Uuidv47::SipHash.siphash24(input, k0_2, k1_2)

    refute_equal result1, result2
  end
end
