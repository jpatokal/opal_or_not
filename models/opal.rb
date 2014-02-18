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
    # Collapse repeated modes
    daily_fare = @data.uniq {|a| a[:mode]}.map do |segment|
      single(segment) * (one_way ? 1 : 2)
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
