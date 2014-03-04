require 'pg'

require_relative 'opal'
require_relative 'my_multi'
require_relative 'train'

class Comparison
  attr_reader :data

  def initialize(data=[], options={})
    @options = options
    @data = data.map do |hash|
      hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      [:count, :zone].each do |key|
        hash[key] = hash[key].to_i if hash[key]
      end
      hash
    end.sort {|a,b| a[:mode] <=> b[:mode]}
    @stats = {}
  end

  def mode_string
    data.map {|m| m[:mode]}.join('+')
  end

  def fare_types
    [
      Opal,
      TravelTen,
      TrainSingle, TrainWeekly, TrainMonthly, TrainQuarterly,
      MyMultiWeekly, MyMultiMonthly, MyMultiQuarterly
    ]
  end

  def compute()
    fare_types.each do |type|
      fare_class = type.new(@data)
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
    if ENV['DATABASE_URL']
      # Looks like we're on Heroku
      db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
      username = db_parts[3]
      password = db_parts[4]
      host = db_parts[5]
      db = db_parts[7]
      conn = PGconn.open(:host => host, :dbname => db, :user => username, :password => password)
    else
      conn = PGconn.open(:dbname => 'app-dev')
    end
    print "mode_string", mode_string
    conn.exec("UPDATE opal SET count=count+1, sum=sum+#{savings(52)} WHERE name='#{row}' and mode='#{mode_string}';")
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
    @stats["Opal"]["average"] = @stats["Opal"]["sum"] / @stats["Opal"]["count"] if @stats["Opal"]["count"] > 0
    @stats["NonOpal"]["percent"] = @stats["NonOpal"]["count"] * 100 / total
    @stats["NonOpal"]["average"] = @stats["NonOpal"]["sum"] / @stats["NonOpal"]["count"] if @stats["NonOpal"]["count"] > 0
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

