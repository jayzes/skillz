class Test::Unit::TestCase
  def deny(condition, msg=nil)
    if msg
      assert(!condition,msg)
    else
      assert !condition
    end
  end
end