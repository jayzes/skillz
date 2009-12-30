module CoreExtensions
  module TimeExtensions
    def closest_second
      Time.gm(year, month, day, hour, min, sec)
    end
  end
end

class Time
  include CoreExtensions::TimeExtensions
end