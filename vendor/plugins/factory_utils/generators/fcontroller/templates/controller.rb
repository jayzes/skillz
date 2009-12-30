class <%= class_name %>Controller < ApplicationController
<% for action in ( actions || ['index'] ) -%>
  def <%= action %>
  end

<% end -%>
end
