class Fare
  attr_reader :data

  def fare_table
    raise "Fare table not defined"
  end

  def initialize(data=[])
    data = data.map do |hash|
      hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      [:count, :zone].each do |key|
        hash[key] = hash[key].to_i if hash[key]
      end
      hash
    end
    @data = data.sort {|a,b| a[:mode] <=> b[:mode]}
  end

  def name
    self.class.to_s
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

class TravelTen < Fare
  def fare_table
    {
      "bus" => {
        1 => 1.84,
        2 => 2.96,
        3 => 3.68
      },
      "ferry" => {
        1 => 4.80,
        2 => 5.92
      }
    }
  end

  def compute_segment(segment)
    if segment[:mode] == "train"
      nil
    else
      super
    end
  end
end
