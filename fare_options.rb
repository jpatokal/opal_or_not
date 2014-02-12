require_relative 'fare'

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

