require_relative 'fare'

class Opal < Fare
  def fare_table
    {
      "bus" => {
        1 => 2.10,
        2 => 3.50,
        3 => 4.50
      },
      "train" => {
        1 => 3.38,
        2 => 4.20,
        3 => 4.82,
        4 => 6.46,
        5 => 8.30
      },
      "ferry" => {
        1 => 5.74,
        2 => 7.18
      },
      "light-rail" => {
        1 => 2.10,
        2 => 3.50
      }
    }
  end

  def off_peak_discount(segment)
    if segment[:time]
      case segment[:time].values.count('peak')
      when 0
        return 0.7 # return off-peak, 30% off
      when 1
        return 0.85 # single off-peak, 15% off
      end
    end
    1.0 # full fare
  end

  def compute_day(one_way=false)
    # For each mode, new zone is sum of all zones, capped out at highest zone for that mode
    new_zone = {}
    @data.map {|a| a[:mode]}.each do |mode|
      new_zone[mode] = [
        @data.select {|a| a[:mode] == mode}.reduce(0) {|sum, a| sum + a[:zone]} ,
        fare_table[mode].keys.max
      ].min
    end

    # Collapse repeated modes
    daily_fare = @data.uniq {|a| a[:mode]}.map do |segment|
      new_segment = {
        :mode => segment[:mode],
        :zone => new_zone[segment[:mode]],
        :time => segment[:time]
      }
      single(new_segment) * off_peak_discount(new_segment) * (one_way ? 1 : 2)
    end.reduce(:+)

    # Apply daily cap
    daily_fare = 15 if daily_fare > 15
    daily_fare
  end

  def compute_journey
    count = @data.first[:count]
    count = 8 if count > 8
    [compute_day * (count / 2) + compute_day(true) * (count % 2)]
  end
end
