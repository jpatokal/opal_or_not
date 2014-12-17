class LightRail < Fare
  def zone
    raise "Light rail requires paper_zone"
  end

  def paper_zone
    raise "Undefined"
  end

  def single(segment)
    begin
      fare_table[segment[:mode]][segment[:paper_zone]] ||
        (raise "No fare found in class #{self.class.name} for segment #{segment}, zone mismatch")
    rescue
      raise "No fare found in class #{self.class.name} for segment #{segment}, mode mismatch"
    end
  end

  def fare_table
    {
      "light-rail" => {
        1 => paper_zone[0],
        2 => paper_zone[1]
      },
    }
  end
end

class LightRailSingle < LightRail
  def name
    "Light Rail Singles"
  end

  def paper_zone
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

  def paper_zone
    [5.00, 6.20]
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

  def paper_zone
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
