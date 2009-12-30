
Factory.define :<%= singular_name %> do |<%= singular_name.chomp %>|
<% for attribute in attributes -%>
  <%= singular_name.chomp %>.<%= attribute.name %> <%= attribute.default.is_a?(String) ? "'#{attribute.default}'" : attribute.default %>
<% end -%>
end