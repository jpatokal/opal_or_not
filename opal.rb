class FareSegment
  def initialize(segment)
    @count = segment[:count]
    @model = segment[:model]
    @zone = segment[:zone]
  end

  def single
    fare_table[@mode][@zone]
  end

  def compute
    single * @count
  end
end

class Fare
  def initialize(data)
    @data = data
  end

  def compute
    @data.map do |segment|
      FareSegment.new(segment).computer
    end.sum
  end
end

class Opal < Fare
  def fare_table
    {
      :bus => {
        1 => 2.10,
        2 => 3.50,
        3 => 4.50
      },
      :train => {
        1 => 3.30,
        2 => 4.10,
        3 => 4.70,
        4 => 6.30,
        5 => 8.10
      },
      :ferry => {
        1 => 5.60,
        2 => 7.00
      }
    }
  end
end

class OpalSegment < FareSegment
  def compute
    single * (@count > 8 ? 8 : @count)
  end
end

class MyMulti < Fare
  def fare_table
    {
      :bus => {
        1 => 44,
        2 => 44,
        3 => 44
      },
      :train => {
        1 => 44,
        2 => 44,
        3 => 52,
        4 => 52,
        5 => 61
      },
      :ferry => {
        1 => 52,
        2 => 52
      }
    }
  end

  def compute
    fare_table[@mode][@zone]
  end
end

class TravelTen < Fare
  def fare_table
    {
      :bus => {
        1 => 1.84,
        2 => 2.96,
        3 => 3.68
      },
      :ferry => {
        1 => 4.80,
        2 => 5.92
      }
    }
  end

  def compute
    if @mode == :train
      nil
    else
      super
    end
  end
end

class Weekly < Fare
  def compute
    if @mode == :train
      [28, 35, 41, 52, 61][@zone - 1]
    else
      nil
    end
  end
end

class FareOptions
  def initialize(data)
    @options = {}
    [Opal, MyMulti, TravelTen, Weekly].each do |type|
      fare = type.new(data).compute
      @options[type.to_s] = fare if fare
    end
  end

  def all
    @options
  end

  def cheapest(allow_opal=true)
    lowest_price = 100
    for type, price in @options
      if type != 'Opal' or allow_opal
        if price < lowest_price
          lowest_price = price
          lowest_type = type
        end
      end
    end
    lowest_type
  end

  def savings
    if cheapest == 'Opal'
      @options['Opal'] - @options[cheapest(false)]
    else
      @options['Opal'] - @options[cheapest]
    end
  end
end


samples = [
  [{ :mode => :ferry, :zone => 1, :count => 8 }],
  [{ :mode => :ferry, :zone => 1, :count => 9 }],
  [{ :mode => :ferry, :zone => 1, :count => 10 }],
  [{ :mode => :ferry, :zone => 1, :count => 10 }, { :mode => :ferry, :zone => 1, :count => 10 }],
  [{ :mode => :bus,   :zone => 3, :count => 9 }],
  [{ :mode => :bus,   :zone => 3, :count => 10 }],
  [{ :mode => :train,   :zone => 5, :count => 9 }],
  [{ :mode => :train,   :zone => 5, :count => 10 }],
]

samples.each do |data|
  options = FareOptions.new(data)
  puts "Cheapest: #{options.cheapest}"
  puts "Savings over Opal: $%.02f" % options.savings
end
