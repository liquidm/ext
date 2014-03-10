class Integer
  TWO_POWER_WORD1 = 2 ** (1.size * 8 - 1)
  TWO_POWER_WORD = 2 ** (1.size * 8)

  def self.to_signed(number)
    number >= TWO_POWER_WORD1 ? number - TWO_POWER_WORD : number
  end

  def self.to_unsigned(number)
    number < 0 ? number + TWO_POWER_WORD : number
  end
end
