class MyMulti < Fare
  def fare_table
    {
      "bus" => {
        1 => zone[1],
        2 => zone[1],
        3 => zone[1]
      },
      "train" => {
        1 => zone[1],
        2 => zone[2],
        3 => zone[2],
        4 => zone[3],
        5 => zone[3]
      },
      "ferry" => {
        1 => zone[2],
        2 => zone[3]
      },
      "light_rail" => {
        1 => zone[1],
        2 => zone[1]
      },
    }
  end

  def zone
    raise "Undefined"
  end

  def single segment
    case segment[:cbd_distance]
    when nil
      super
    when 0..10
      zone[1]
    when 10..35
      zone[2]
    else
      zone[3]
    end
  end

  def compute_journey
    # Only compute MyMulti if there are multiple segments
    return [nil] if @data.length < 2

    # MyMulti option that covers most expensive single segment suffices for entire journey
    [@data.map do |segment|
      compute_segment segment
    end.sort.last]
  end

  def compute_segment(segment)
    single segment
  end
end

class MyMultiWeekly < MyMulti
  def name
    "MyMulti Weekly"
  end

  def zone
    [0, 46, 54, 63]
  end
end

class MyMultiMonthly < MyMulti
  def name
    "MyMulti Monthly"
  end

  def zone
    [0, 175.0, 206.0, 246.0].map {|a| a / (28.0 / 7.0)}
  end
end

class MyMultiQuarterly < MyMulti
  def name
    "MyMulti Quarterly"
  end

  def zone
    [0, 484.0, 567.0, 676.0].map {|a| a / (90.0 / 7.0)}
  end
end
