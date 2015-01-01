class Train < Fare
  def zone
    raise "Undefined"
  end

  def fare_table
    {
      "train" => {
        1 => zone[0],
        2 => zone[1],
        3 => zone[2],
        4 => zone[3],
        5 => zone[4]
      },
    }
  end
end

class TrainSingle < Train
  def name
    "MyTrain Singles"
  end

  def zone
    [4.00, 4.80, 5.40, 7.00, 8.80]
  end

  def compute_segment(segment)
    if segment[:mode] == "train" and segment[:count] < 8
      super
    else
      nil
    end
  end
end

class TrainOffPeakReturn < Train
  def name
    "MyTrain Off-Peak Returns"
  end

  def zone
    [5.00, 6.20, 7.00, 9.20, 11.80]
  end

  def off_peak?(segment)
    segment[:mode] == "train" and segment[:time] and segment[:time][:am] == "after"
  end

  def compute_segment(segment)
    if off_peak?(segment)
      super / 2  # super is a single fare, not returns
    else
      nil
    end
  end
end

class TrainWeekly < Train
  def name
    "MyTrain Weekly"
  end

  def zone
    [28, 35, 41, 52, 61]
  end

  def compute_segment(segment)
    if segment[:mode] == "train" and segment[:count] > 4
      single segment
    else
      nil
    end
  end
end

class TrainMonthly < TrainWeekly
  def name
    "MyTrain Monthly"
  end

  def zone
    [102.0, 127.0, 149.0, 189.0, 222.0].map {|a| a / (28.0 / 7.0)}
  end
end

class TrainQuarterly < TrainWeekly
  def name
    "MyTrain Quarterly"
  end

  def zone
    [280.0, 350.0, 410.0, 520.0, 610.0].map {|a| a / (90.0 / 7.0)}
  end
end
