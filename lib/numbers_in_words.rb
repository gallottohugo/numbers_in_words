require "numbers_in_words/version"
require 'numbers_in_words/language_writer'

require 'numbers_in_words/english/constants'
require 'numbers_in_words/english/language_writer_english'

require 'numbers_in_words/number_group'
require 'numbers_in_words/number_parser'
require 'numbers_in_words/to_number'
require 'numbers_in_words/to_word'

module NumbersInWords
  LENGTH_OF_GOOGOL      = 101 #length of the string i.e. one with 100 zeros
  Error                 = ::Class.new(::StandardError)
  AmbiguousParsingError = ::Class.new(Error)
  DivideByZeroError     = ::Class.new(Error)
  InvalidNumber         = ::Class.new(Error)

  class << self
    attr_writer :language

    def language
      @language ||= "English"
    end

    def in_words(i, language: NumbersInWords.language, only_compress: false, fraction: false)
      ToWord.new(i, language: language).in_words(only_compress: only_compress, fraction: fraction)
    end

    def in_numbers(s, language: NumbersInWords.language, only_compress: false)
      ToNumber.new(s, language: language).in_numbers(only_compress: only_compress)
    end

    def ordinal(s)
      ToWord.new(s).ordinal
    end
  end
end

