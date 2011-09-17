
class Integer
  def to_comma(d = 10)
    s = self.to_s.gsub(/([0-9])(?=([0-9]{3})+(?![0-9]))/) { $1 + ',' }
    if d && s.length < d then
      s = " " * (d - s.length) + s
    else
      s
    end
  end

  def change_ratio(a)
    if a && a > 0 then
      self * 1.0 / a - 1.0
    else
      nil
    end
  end

  def ratio(a)
    if a && a > 0 then
      self * 1.0 / a
    else
      nil
    end
  end
end

class Float
  def to_percent(d=10)
    s = sprintf("%6.1f%%", self * 100.0)
    if d && s.length < d then
      s = " " * (d - s.length) + s
    else
      s
    end
  end

  def to_s_percent(d=10)
    s = sprintf("%+6.1f%%", self * 100.0)
    if d && s.length < d then
      s = " " * (d - s.length) + s
    else
      s
    end
  end
end

class Date
  def last_monday
    if self.wday >= 1 then
      self - self.wday + 1
    else
      self - 6
    end
  end

  def to_ss
    self.strftime("%Y-%m-%d 00:00:00")
  end

  def wday_name
    ['日', '月', '火', '水', '木', '金', '土'][self.wday]
  end
end

def nz(a)
  if a && a > 0 then
    true
  else
    false
  end
end

def if_not_zero(a, b, c)
  if a && a > 0 then
    b
  else
    c
  end
end

