#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uuidv47'

# Demo script for Uuidv47 Ruby gem
puts '=== UUIDv47 Ruby Demo ==='
puts

# Example 1: Parse UUID and encode/decode
puts 'Example 1: Basic encode/decode'
puts '-' * 40

v7_str = '00000000-0000-7000-8000-000000000000'
v7 = Uuidv47::UUID.new(v7_str)
puts "Original v7: #{v7} (version: #{v7.version})"

key = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)
puts "Key: #{key.to_hex}"

v4_facade = v7.encode_v4facade(key)
puts "v4 facade:   #{v4_facade} (version: #{v4_facade.version})"

v7_back = Uuidv47::UUID.decode_v4facade(v4_facade, key)
puts "Decoded v7:  #{v7_back} (version: #{v7_back.version})"

puts "Round-trip successful: #{v7.bytes == v7_back.bytes}"
puts

# Example 2: Generate new UUIDv7
puts 'Example 2: Generate new UUIDv7'
puts '-' * 40

new_v7 = Uuidv47::UUID.new
puts "Generated v7: #{new_v7} (version: #{new_v7.version})"

v4_new = new_v7.encode_v4facade(key)
puts "As v4 facade: #{v4_new} (version: #{v4_new.version})"

v7_decoded = Uuidv47::UUID.decode_v4facade(v4_new, key)
puts "Decoded back: #{v7_decoded} (version: #{v7_decoded.version})"
puts

# Example 3: Different keys produce different facades
puts 'Example 3: Different keys produce different facades'
puts '-' * 40

key1 = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)
key2 = Uuidv47::Key.new(0xdeadbeefcafebabe, 0x1234567890abcdef)

test_uuid = Uuidv47::UUID.new('01921e83-7c3a-7000-8000-000000000001')
puts "Original v7:     #{test_uuid}"

facade1 = test_uuid.encode_v4facade(key1)
facade2 = test_uuid.encode_v4facade(key2)

puts "Facade with key1: #{facade1}"
puts "Facade with key2: #{facade2}"
puts "Facades are different: #{facade1.bytes != facade2.bytes}"
puts

# Example 4: Random key generation
puts 'Example 4: Random key generation'
puts '-' * 40

random_key = Uuidv47::Key.new
puts "Random key: #{random_key.to_hex}"

# Key from hex string
key_from_hex = Uuidv47::Key.from_hex(random_key.to_hex)
puts "Key from hex: #{key_from_hex.to_hex}"
puts "Keys match: #{random_key.k0 == key_from_hex.k0 && random_key.k1 == key_from_hex.k1}"
