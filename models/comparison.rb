require_relative 'opal'
require 'pg'

class Comparison
  def initialize(options={})
    @options = options
    @stats = {}
  end

  def fare_types
    [Opal, MyMulti, TravelTen, TrainSingle, Weekly]
  end

  def compute(data)
    fare_types.each do |type|
      fare_class = type.new(data)
      fare = fare_class.compute
      @options[fare_class.name] = fare if fare
    end
    self
  end

  def all
    @options
  end

  def table
    fare_array = @options.to_a.sort { |x,y| x.last <=> y.last }.map do |fare|
      if fare.first == 'Opal'
        color = '#4582EC'
      else
        color = (fare.first == cheapest) ? '#3FAD46' : 'gray'
      end
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
      @options[cheapest(false)] - @options['Opal']
    else
      @options['Opal'] - @options[cheapest]
    end * weeks
  end

  def record
    row = cheapest == 'Opal' ? 'Opal' : 'Non-Opal'
    conn = PGconn.open(:dbname => 'opaldb')
    conn.exec("UPDATE opal SET count=count+1, sum=sum+#{savings(52)} WHERE name='#{row}';")
    total = 0
    conn.exec("SELECT name, count, sum FROM opal;") do |result|
      result.each_row do |row|
        name, count, sum = row
        total += count.to_i
        @stats[name.delete('-')] = { "count" => count.to_i, "sum" => sum.to_f }
      end
    end
    @stats["count"] = total
    @stats["Opal"]["percent"] = @stats["Opal"]["count"] * 100 / total
    @stats["NonOpal"]["percent"] = @stats["NonOpal"]["count"] * 100 / total
    conn.close
    self
  end

  def result
    {
      "winner" => cheapest,
      "alternative" => cheapest(false),
      "savings" => {
        "week" => savings,
        "year" => savings(52)
      },
      "table" => table,
      "stats" => @stats
    }
  end
end

