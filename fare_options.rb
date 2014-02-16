require_relative 'fare'

class FareOptions
  def initialize(options={})
    @options = options
  end

  def compute(data)
    [Opal, MyMulti, TravelTen, Weekly].each do |type|
      fare = type.new(data).compute
      @options[type.to_s] = fare if fare
    end
    self
  end

  def all
    @options
  end

  def table
    fare_array = @options.to_a.sort { |x,y| x.last <=> y.last }.map do |fare|
      color = (fare.first == cheapest) ? '#4582EC' : 'gray'
      fare.push(color, "$%.02f" % fare.last)
    end
    fare_array.unshift ['Ticket', 'Weekly cost', { role: 'style' }, { role: 'annotation' } ]
    fare_array
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

  def savings(weeks=1)
    if cheapest == 'Opal'
      @options['Opal'] - @options[cheapest(false)]
    else
      @options['Opal'] - @options[cheapest]
    end * weeks
  end

  def result
    {
      "winner" => cheapest,
      "alternative" => cheapest(false),
      "savings" => {
        "week" => savings,
        "year" => savings(52)
      },
      "table" => table
    }
  end
end

