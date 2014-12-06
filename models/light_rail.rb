class LightRail < Fare
  def zone
    raise "Undefined"
  end

  def fare_table
    {
      "light-rail" => {
        1 => zone[0],
        2 => zone[1]
      },
    }
  end
end

class LightRailSingle < LightRail
  def name
    "Light Rail Singles"
  end

  def zone
    [3.60, 4.60]
  end

  def compute_segment(segment)
    if segment[:mode] == "light-rail" and segment[:count] < 8
      super
    else
      nil
    end
  end
end

class LightRailReturn < LightRail
  def name
    "Light Rail Returns"
  end

  def zone
    [5.00, 6.20]
  end

  def off_peak?(segment)
    segment[:mode] == "train" and segment[:time] and segment[:time][:am] == "after"
  end

  def compute_segment(segment)
    if segment[:mode] == "light-rail"
      super / 2  # super is a single fare, not returns
    else
      nil
    end
  end
end

class LightRailWeekly < LightRail
  def name
    "Light Rail Weekly"
  end

  def zone
    [23, 23]
  end

  def compute_segment(segment)
    if segment[:mode] == "light-rail" and segment[:count] > 4
      single segment
    else
      nil
    end
  end
end
