class Fare
  attr_reader :data

  def fare_table
    raise "Fare table not defined"
  end

  def initialize(data=[])
    @data = data
  end

  def name
    self.class.to_s
  end

  def single(segment)
    begin
      fare_table[segment[:mode]][segment[:zone]] ||
        (raise "No fare found in class #{self.class.name} for segment #{segment}, zone mismatch")
    rescue
      raise "No fare found in class #{self.class.name} for segment #{segment}, mode mismatch"
    end
  end

  def compute_segment(segment)
    # Round to two decimal places
    (single(segment) * segment[:count] * 100).round / 100.0
  end

  def compute_journey
    @data.map do |segment|
      compute_segment segment
    end
  end

  def compute
    fares = compute_journey
    if fares.include? nil
      nil
    else
      fares.reduce(:+)
    end
  end
end

class BusTravelTen < Fare
  def name
    "Bus TravelTen"
  end

  def fare_table
    {
      "bus" => {
        1 => 1.84,
        2 => 2.96,
        3 => 3.68
      }
    }
  end

  def compute_segment(segment)
    if segment[:mode] == "bus"
      super
    else
      nil
    end
  end
end

class FerryTravelTen < Fare
  def name
    "Ferry TravelTen"
  end

  def fare_table
    {
      "ferry" => {
        1 => 4.80,
        2 => 5.92
      }
    }
  end

  def compute_segment(segment)
    if segment[:mode] == "ferry"
      super
    else
      nil
    end
  end
end
