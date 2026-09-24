# frozen_string_literal: true

class ShortCodeService
  CHARSET = ("a".."z").to_a + ("0".."9").to_a
  MAX_ATTEMPTS = 10

  def self.generate
    Array.new(6) { CHARSET.sample }.join
  end

  def self.generate_unique(existing_codes:)
    MAX_ATTEMPTS.times do
      code = generate
      return code unless existing_codes.include?(code)
    end
    generate
  end
end
