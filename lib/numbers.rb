require 'rubygems'
require 'active_support'
module NumbersInWords

  #handle exceptions to normal numbers
  EXCEPTIONS = {10=> "ten", 11=>"eleven", 12 => "twelve", 13 => "thirteen", 
    14=>"fourteen", 15=>"fifteen", 16=>"sixteen" , 
    17=> "seventeen", 18=> "eighteen", 19=> "nineteen", 
    20 => "twenty", 30=>"thirty", 
    40=>"forty", 50=>"fifty", 60 => "sixty", 70=> "seventy", 80=>"eighty", 
    90 => "ninety"}

  DIGITS= %w[zero one two three four five six seven eight nine]
  POWERS_OF_TEN ={0=>"one", 1 => "ten", 2=> "hundred", 
    3 => "thousand", 6=>"million",
    9=>"billion", 
    12=>"trillion",
    15=>"quadrillion",
    18=>"quintillion", 
    21=>"sextillion",
    24=>"septillion", 
    27=>"octillion", 
    30=>"nonillion", 
    33=>"decillion",
    36=>"undecillion", 
    39=>"duodecillion",
    42=>"tredecillion", 
    45=>"quattuordecillion", 
    48=>"quindecillion",
    51=>"sexdecillion", 
    54=>"septendecillion",
    57=>"octodecillion", 
    60=>"novemdecillion", 
    63=>"vigintillion",
    66=>"unvigintillion", 
    69=>"duovigintillion", 
    72=>"trevigintillion",
    75=>"quattuorvigintillion",
    78=>"quinvigintillion", 
    81=>"sexvigintillion",
    84=>"septenvigintillion", 
    87=>"octovigintillion",
    90=>"novemvigintillion", 
    93=>"trigintillion",
    96=>"untrigintillion", 
    99=>"duotrigintillion",
    100 => "googol"
  }
  LENGTH_OF_GOOGOL = 101 #length of the string i.e. one with 100 zeros
  def in_english
    #decimals
    d= handle_decimal(self)
    return d unless d.nil?


    number = self.to_i # make a copy
    #negative numbers
    return "minus " + (-number).in_english if number < 0

    #handle 0-10
    return DIGITS[number] if number < 10
    return EXCEPTIONS[number] if EXCEPTIONS[number]

    #longer numbers
    output = ""
    length = number.to_s.length
    if length == 2 #20-99
      tens = (number/10).round*10 #write the tens
      # e.g. eighty
      output << EXCEPTIONS[tens]
      #write the digits
      digit= number - tens
      output << " " + digit.in_english unless digit==0
    elsif length == 3
      #e.g. 113 splits into "one hundred" and "thirteen"
      output << number.english_group(2)
    elsif length < LENGTH_OF_GOOGOL #more than one hundred less than one googol
      output << number.english_group(3)
    elsif length == LENGTH_OF_GOOGOL 
      output << number.in_googols
    elsif length > LENGTH_OF_GOOGOL #one googol and larger
      output << number.split_googols
    end

    return output.strip
  end

  def in_words language="English"
    case language
    when "English" #allow for I18n
      in_english
    end
  end

  def groups_of size
    i=self.to_i
    #split into groups this gives us 1234567 => 123 456 7
    #so we need to reverse first
    #in stages
    #i.e. 1234567 => 7654321     
    groups = i.to_s.reverse
    #7654321 => 765 432 1
    groups = groups.split("").in_groups_of(size)
    #765 432 1 => 1 432 765
    groups.reverse!
    #1 432 765 => 1 234 567
    groups.map! {|group| group.reverse}

    #turn back into integers
    groups.map! {|group|  group.join("").to_i }
    groups.reverse! # put in ascending order of power of ten

    #output hash where key is the power of ten
    #and value if the multiplier
    power = 0
    return groups.inject({}) do |output, digits|
      output[power]=digits
      power+=size
      output
    end

  end

  def group_words size, language="English"
    #1000 and over Numbers are split into groups of three
    number = self.to_i
    groups = number.groups_of(size)
    powers = groups.keys.sort.reverse #put in descending order
    powers.each do |power|
      name = POWERS_OF_TEN[power] if language=="English"
      digits = groups[power]
      yield power, name, digits
    end

  end

  def english_group group_size
    number = self.to_i
    output = ""
    number.group_words(group_size) do |power, name, digits|
      if digits > 0
        prefix = " "
        #no 'and' between thousands and hundreds
        prefix << "and " if power == 0 and digits < 100
        output << prefix + digits.in_english
        output << prefix + name unless power == 0
      end
    end
    return output
  end

  def split_googols
    number = self.to_i
    output = ""
    googols = number.to_s[0..(-LENGTH_OF_GOOGOL)].to_i
    remainder = number.to_s[1-LENGTH_OF_GOOGOL .. -1].to_i
    output << " " + googols.in_words + " googol" 
    if remainder > 0
      prefix = " "
      prefix << "and " if remainder < 100
      output << prefix + remainder.in_english
    end
    return output
  end

  def in_googols

    number = self.to_i
    output = ""
    output << " " + number.to_s[0..0].to_i.in_english + " googol"
    remainder = number.to_s[1..-1].to_i
    prefix = " "
    prefix << "and " if remainder < 100
    output << prefix + remainder.in_english if remainder > 0

    return output
  end

  def handle_decimal value
    if value.is_a? Float
      int = value.to_i
      decimal = value - int
      return int.in_english + " point " + decimal_portion(decimal)
    end
    return nil
  end

  def decimal_portion decimal
    decimal = decimal.to_s.split(".")[1]
    digits = decimal.to_s.split //
    out= digits.inject([]) {|out, digit|
      out<< digit.to_i.in_english
      out
    }
    out.join " "

  end


end

#Extending the Fixnum class to support converting to words
class Fixnum
  include NumbersInWords
end

#Extending the Bignum class to support converting to words
class Bignum
  include NumbersInWords
end

#Extending the Float class to support converting to words
class Float
  include NumbersInWords
end