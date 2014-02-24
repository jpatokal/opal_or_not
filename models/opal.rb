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
        1 => 3.30,
        2 => 4.10,
        3 => 4.70,
        4 => 6.30,
        5 => 8.10
      },
      "ferry" => {
        1 => 5.60,
        2 => 7.00
      }
    }
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
        :zone => new_zone[segment[:mode]]
      }
      single(new_segment) * (one_way ? 1 : 2)
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
