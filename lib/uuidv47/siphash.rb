# frozen_string_literal: true

module Uuidv47
  module SipHash
    INIT_V0 = 0x736f6d6570736575
    INIT_V1 = 0x646f72616e646f6d
    INIT_V2 = 0x6c7967656e657261
    INIT_V3 = 0x7465646279746573

    class << self
      def siphash24(data, k0, k1)
        v0 = INIT_V0 ^ k0
        v1 = INIT_V1 ^ k1
        v2 = INIT_V2 ^ k0
        v3 = INIT_V3 ^ k1

        blocks = data.length / 8
        blocks.times do |i|
          m = data[i * 8, 8].unpack1('Q<')
          v3 ^= m
          2.times do
            v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
          end
          v0 ^= m
        end

        tail = data[(blocks * 8)..]
        b = (data.length << 56)

        if tail.length > 0
          tail_bytes = tail.bytes
          t = 0
          tail_bytes.each_with_index do |byte, i|
            t |= (byte << (i * 8))
          end
          b |= t
        end

        v3 ^= b
        2.times do
          v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
        end
        v0 ^= b

        v2 ^= 0xff
        4.times do
          v0, v1, v2, v3 = sipround(v0, v1, v2, v3)
        end

        v0 ^ v1 ^ v2 ^ v3
      end

      private

      def sipround(v0, v1, v2, v3)
        v0 = (v0 + v1) & 0xFFFFFFFFFFFFFFFF
        v2 = (v2 + v3) & 0xFFFFFFFFFFFFFFFF
        v1 = rotl64(v1, 13)
        v3 = rotl64(v3, 16)
        v1 ^= v0
        v3 ^= v2
        v0 = rotl64(v0, 32)
        v2 = (v2 + v1) & 0xFFFFFFFFFFFFFFFF
        v0 = (v0 + v3) & 0xFFFFFFFFFFFFFFFF
        v1 = rotl64(v1, 17)
        v3 = rotl64(v3, 21)
        v1 ^= v2
        v3 ^= v0
        v2 = rotl64(v2, 32)
        [v0, v1, v2, v3]
      end

      def rotl64(x, b)
        ((x << b) | (x >> (64 - b))) & 0xFFFFFFFFFFFFFFFF
      end
    end
  end
end
