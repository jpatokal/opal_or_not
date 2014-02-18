class Fare
  attr_reader :data

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

  def compute_journey
    # Collapse same-mode transfers, since they're free with Opal
    # TODO daily fare cap $15
    @data.uniq {|a| a[:mode]}.map do |segment|
      compute_segment segment
    end
  end

#  days = (count > 8 ? 8 : count) / 2
#  for i in range days
#    compute_day
#  end

#  def compute_day
# for each segment...
#    compute_single_segment
# if > 15 then 15

  def compute_segment(segment)
    count = segment[:count]
    single(segment) * (count > 8 ? 8 : count)
  end
end

class MyMulti < Fare
  def fare_table
    {
      "bus" => {
        1 => 46,
        2 => 46,
        3 => 46
      },
      "train" => {
        1 => 46,
        2 => 46,
        3 => 54,
        4 => 54,
        5 => 63
      },
      "ferry" => {
        1 => 54,
        2 => 54
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

class TrainSingle < Fare
  def name
    "MyTrain Singles"
  end

  def fare_table
    {
      "train" => {
        1 => 3.80,
        2 => 4.60,
        3 => 5.20,
        4 => 6.80,
        5 => 8.60
      },
    }
  end

  def compute_segment(segment)
    if segment[:mode] != "train"
      nil
    else
      super
    end
  end
end

class Weekly < Fare
  def name
    "MyTrain Weekly"
  end

  def compute_segment(segment)
    if segment[:mode] == "train"
      [28, 35, 41, 52, 61][segment[:zone] - 1]
    else
      nil
    end
  end
end
