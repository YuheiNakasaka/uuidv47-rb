# frozen_string_literal: true

require_relative 'uuidv47/version'
require_relative 'uuidv47/siphash'
require 'securerandom'

module Uuidv47
  class Error < StandardError; end

  class Key
    attr_reader :k0, :k1

    def initialize(k0 = nil, k1 = nil)
      if k0.nil? || k1.nil?
        random_bytes = SecureRandom.random_bytes(16)
        @k0 = random_bytes[0, 8].unpack1('Q<')
        @k1 = random_bytes[8, 8].unpack1('Q<')
      else
        @k0 = k0
        @k1 = k1
      end
    end

    def self.from_hex(hex_string)
      parts = hex_string.split(':')
      raise ArgumentError, 'Invalid key format' unless parts.length == 2

      k0 = parts[0].to_i(16)
      k1 = parts[1].to_i(16)
      new(k0, k1)
    end

    def to_hex
      format('%016x:%016x', @k0, @k1)
    end
  end

  class UUID
    attr_reader :bytes

    def initialize(bytes = nil)
      if bytes.nil?
        @bytes = generate_v7_bytes
      elsif bytes.is_a?(String)
        if bytes.length == 16
          @bytes = bytes
        elsif bytes.length == 36
          @bytes = parse_uuid_string(bytes)
        else
          raise ArgumentError, 'Invalid UUID input'
        end
      elsif bytes.is_a?(Array)
        raise ArgumentError, 'Invalid byte array length' unless bytes.length == 16

        @bytes = bytes.pack('C*')
      else
        raise ArgumentError, 'Invalid UUID input type'
      end
    end

    def version
      (@bytes[6].ord >> 4) & 0x0F
    end

    def set_version(ver)
      @bytes[6] = ((@bytes[6].ord & 0x0F) | ((ver & 0x0F) << 4)).chr
    end

    def set_variant_rfc4122
      @bytes[8] = ((@bytes[8].ord & 0x3F) | 0x80).chr
    end

    def to_s
      hex = @bytes.unpack1('H*')
      format('%s-%s-%s-%s-%s',
             hex[0, 8],
             hex[8, 4],
             hex[12, 4],
             hex[16, 4],
             hex[20, 12])
    end

    def encode_v4facade(key)
      msg = build_sip_message

      mask48 = SipHash.siphash24(msg, key.k0, key.k1) & 0x0000FFFFFFFFFFFF

      ts48 = read_48be(@bytes[0, 6])

      enc_ts = ts48 ^ mask48

      facade_bytes = @bytes.dup
      write_48be(facade_bytes, 0, enc_ts)

      facade = UUID.new(facade_bytes)
      facade.set_version(4)
      facade.set_variant_rfc4122
      facade
    end

    def self.decode_v4facade(facade, key)
      msg = facade.build_sip_message

      mask48 = SipHash.siphash24(msg, key.k0, key.k1) & 0x0000FFFFFFFFFFFF

      enc_ts = read_48be(facade.bytes[0, 6])

      ts48 = enc_ts ^ mask48

      v7_bytes = facade.bytes.dup
      write_48be(v7_bytes, 0, ts48)

      v7 = new(v7_bytes)
      v7.set_version(7)
      v7.set_variant_rfc4122
      v7
    end

    def build_sip_message
      msg = String.new(encoding: 'ASCII-8BIT')
      msg << (@bytes[6].ord & 0x0F).chr
      msg << @bytes[7]
      msg << (@bytes[8].ord & 0x3F).chr
      msg << @bytes[9, 7]
      msg
    end

    private

    def generate_v7_bytes
      ts_ms = (Time.now.to_f * 1000).to_i
      ts48 = ts_ms & 0x0000FFFFFFFFFFFF

      random_bytes = SecureRandom.random_bytes(10)

      bytes = String.new(encoding: 'ASCII-8BIT')

      bytes << ((ts48 >> 40) & 0xFF).chr
      bytes << ((ts48 >> 32) & 0xFF).chr
      bytes << ((ts48 >> 24) & 0xFF).chr
      bytes << ((ts48 >> 16) & 0xFF).chr
      bytes << ((ts48 >> 8) & 0xFF).chr
      bytes << (ts48 & 0xFF).chr

      bytes << (0x70 | (random_bytes[0].ord & 0x0F)).chr # version 7
      bytes << random_bytes[1]

      bytes << ((random_bytes[2].ord & 0x3F) | 0x80).chr # RFC variant
      bytes << random_bytes[3, 7]

      bytes
    end

    def parse_uuid_string(str)
      hex = str.gsub('-', '')
      raise ArgumentError, 'Invalid UUID string' unless hex.match?(/\A[0-9a-fA-F]{32}\z/)

      [hex].pack('H*')
    end

    def self.read_48be(bytes)
      bytes[0].ord << 40 |
        bytes[1].ord << 32 |
        bytes[2].ord << 24 |
        bytes[3].ord << 16 |
        bytes[4].ord << 8 |
        bytes[5].ord
    end

    def read_48be(bytes)
      self.class.read_48be(bytes)
    end

    def self.write_48be(bytes, offset, value)
      bytes[offset] = ((value >> 40) & 0xFF).chr
      bytes[offset + 1] = ((value >> 32) & 0xFF).chr
      bytes[offset + 2] = ((value >> 24) & 0xFF).chr
      bytes[offset + 3] = ((value >> 16) & 0xFF).chr
      bytes[offset + 4] = ((value >> 8) & 0xFF).chr
      bytes[offset + 5] = (value & 0xFF).chr
    end

    def write_48be(bytes, offset, value)
      self.class.write_48be(bytes, offset, value)
    end
  end

  def self.encode_v4facade(v7, key)
    uuid = v7.is_a?(UUID) ? v7 : UUID.new(v7)
    uuid.encode_v4facade(key)
  end

  def self.decode_v4facade(v4_facade, key)
    uuid = v4_facade.is_a?(UUID) ? v4_facade : UUID.new(v4_facade)
    UUID.decode_v4facade(uuid, key)
  end
end
