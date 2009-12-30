module WithHoptoadNotification
  def with_hoptoad_notification
    yield
  rescue Exception => e
    HoptoadNotifier.notify(e)
    raise e
  end
end

class Object
  include WithHoptoadNotification
end