# UUIDv47-rb

This is a reimplementation of [stateless-me/uuidv47](https://github.com/stateless-me/uuidv47) to Ruby. It's a pure Ruby implementation of UUIDv47 — UUIDv7-in / UUIDv4-out (SipHash‑masked timestamp)

`uuidv47` lets you store sortable UUIDv7 in your database while emitting a UUIDv4‑looking façade at your API boundary. It XOR‑masks *only* the UUIDv7 timestamp field with a keyed SipHash‑2‑4 stream derived from the UUID's own random bits. The mapping is deterministic and exactly invertible.

## Features

- Deterministic, invertible mapping (exact round‑trip)
- RFC‑compatible version/variant bits (v7 in DB, v4 on the wire)
- Key‑recovery resistant (SipHash‑2‑4, 128‑bit key)
- Pure Ruby implementation
- Full test coverage

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uuidv47'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install uuidv47
```

## Usage

### Quick Start

```ruby
require 'uuidv47'

# Parse a UUIDv7
v7 = Uuidv47::UUID.new("00000000-0000-7000-8000-000000000000")

# Create a key
key = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)

# Or generate a random key
random_key = Uuidv47::Key.new

# Encode to v4 facade
v4_facade = v7.encode_v4facade(key)
puts "v7 (DB) : #{v7}"
puts "v4 (API): #{v4_facade}"

# Decode back to v7
v7_back = Uuidv47::UUID.decode_v4facade(v4_facade, key)
puts "back    : #{v7_back}"
```

### Generate UUIDv7

```ruby
# Generate a new UUIDv7 with current timestamp
uuid = Uuidv47::UUID.new
puts "Generated: #{uuid}"
puts "Version: #{uuid.version}"  # => 7
```

### Key Management

```ruby
# Create key from hex string
key = Uuidv47::Key.from_hex("0123456789abcdef:fedcba9876543210")

# Export key to hex
hex = key.to_hex  # => "0123456789abcdef:fedcba9876543210"

# Generate random key
random_key = Uuidv47::Key.new
```

### Convenience Methods

```ruby
# Works with string input
v7_str = "01921e83-7c3a-7000-8000-000000000001"
key = Uuidv47::Key.new(0x0123456789abcdef, 0xfedcba9876543210)

v4 = Uuidv47.encode_v4facade(v7_str, key)
v7_back = Uuidv47.decode_v4facade(v4, key)

# Also works with UUID objects
v7_uuid = Uuidv47::UUID.new(v7_str)
v4 = Uuidv47.encode_v4facade(v7_uuid, key)
```

## Why UUIDv47?

- **DB‑friendly**: UUIDv7 is time‑ordered → better index locality & pagination
- **Externally neutral**: The façade hides timing patterns and looks like v4 to clients/systems
- **Secret safety**: Uses a PRF (SipHash‑2‑4). Non‑crypto hashes are not suitable when the key must not leak

## Integration Tips

- Do encode/decode at the API boundary; keep v7 in storage
- For sharding/partitioning, hash the v4 façade
- Keep your key material in a KMS; include a small key ID with each row

## Testing

Run the test suite:

```bash
bundle exec rake test
```

## License

This software is released under the [The MIT License](LICENSE).

Copyright (c) 2025 Yuhei Nakasaka
Released under [the MIT license](LICENSE).