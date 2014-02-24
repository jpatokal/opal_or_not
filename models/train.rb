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
    [3.80, 4.60, 5.20, 6.80, 8.60]
  end

  def compute_segment(segment)
    if segment[:mode] == "train"
      super
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
    if segment[:mode] == "train"
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
    [102.0, 127.0, 149.0, 189.0, 222.0].map {|a| a / (28 / 7)}
  end
end

class TrainQuarterly < TrainWeekly
  def name
    "MyTrain Quarterly"
  end

  def zone
    [280.0, 350.0, 410.0, 520.0, 610.0].map {|a| a / (90 / 7)}
  end
end
