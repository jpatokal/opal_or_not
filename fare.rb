class Fare
  attr_reader :data

  def initialize(data=[])
    @data = data.sort {|a,b| a[:mode] <=> b[:mode]}
  end

  def single(segment)
    begin
      fare_table[segment[:mode]][segment[:zone]]
    rescue
      raise "No fare found in class #{self.class.name} for segment #{segment}"
    end
  end

  def compute_segment(segment)
    # Truncate to two decimal places
    (single(segment) * segment[:count] * 100).to_i / 100.0
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

class Opal < Fare
  def fare_table
    {
      :bus => {
        1 => 2.10,
        2 => 3.50,
        3 => 4.50
      },
      :train => {
        1 => 3.30,
        2 => 4.10,
        3 => 4.70,
        4 => 6.30,
        5 => 8.10
      },
      :ferry => {
        1 => 5.60,
        2 => 7.00
      }
    }
  end

  def compute_journey
    # Collapse same-mode transfers, since they're free with Opal
    @data.uniq {|a| a[:mode]}.map do |segment|
      compute_segment segment
    end
  end

  def compute_segment(segment)
    count = segment[:count]
    single(segment) * (count > 8 ? 8 : count)
  end
end

class MyMulti < Fare
  def fare_table
    {
      :bus => {
        1 => 44,
        2 => 44,
        3 => 44
      },
      :train => {
        1 => 44,
        2 => 44,
        3 => 52,
        4 => 52,
        5 => 61
      },
      :ferry => {
        1 => 52,
        2 => 52
      }
    }
  end

  def compute_journey
    # MyMulti option that covers most expensive single segment suffices for entire journey
    [@data.map do |segment|
      compute_segment segment
    end.sort.last]
  end

  def compute_segment(segment)
    single segment
  end
end

class TravelTen < Fare
  def fare_table
    {
      :bus => {
        1 => 1.84,
        2 => 2.96,
        3 => 3.68
      },
      :ferry => {
        1 => 4.80,
        2 => 5.92
      }
    }
  end

  def compute_segment(segment)
    if segment[:mode] == :train
      nil
    else
      super
    end
  end
end

class Weekly < Fare
  def compute_segment(segment)
    if segment[:mode] == :train
      [28, 35, 41, 52, 61][segment[:zone] - 1]
    else
      nil
    end
  end
end
