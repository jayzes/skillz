# Freeze Time.now
class Test::Unit::TestCase
  def freeze_time
    now = Time.now
    Time.stubs(:now).returns(now)
  end
end