# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include SortableTable::App::Helpers::ApplicationHelper
  
  def flash_messages
     messages = ''
     %w{ notice success warning error }.each do |type|
       messages += content_tag(:div,
         content_tag(:div, flash[type.to_sym] || flash.now[type.to_sym]),
         :class => type + ' message'
         ) if flash[type.to_sym] || flash.now[type.to_sym]
     end
     messages.blank? ? '' : content_tag(:div, messages, :class => 'flash-messages', :id => 'flash_messages')
   end

   def breadcrumbs(first = ['Home', '/'], last = nil)
     result = []
     result << link_to(first.is_a?(Array) ? first[0] : first, first.is_a?(Array) ? first[1] : '/')
     loop_over_path_segments do |i, segments, title, link_extra|
       result << link_to(title, '/' + (0..(i)).collect{|seg| segments[seg]}.join("/") + link_extra)
     end
     url = request.path.split('?')
     result[-1] = link_to(last.is_a?(Array) ? last[0] : last, last.is_a?(Array) ? last[1] : url[0]) if last
     result.collect! {|segment| segment = content_tag(:li, segment, :class => (segment == result.first) ? 'first' : (segment == result.last) ? 'current' : '') }
     content_tag(:ul, result.join, :id => 'crumbs')
   end

   def loop_over_path_segments
     url = request.path.split('?')
     previous_title = ''
     segments = url[0].split('/')
     segments.shift
     segments.each_with_index do |segment, i|
       link_extra = ''
       title = segment.gsub(/-/, ' ').titleize
       if title.to_i.to_s == title || title.to_i > 0
         # check for to_param trick (1-title) for grabbing the title
         title = title.strip =~ /^\d+$/ ? previous_title.singularize : title.gsub(/^\d+/,'').strip
         link_extra = '/edit'
       end
       next if title == 'Edit' || title == 'Admin'
       previous_title = title
       yield(i, segments, title, link_extra)
     end
   end
  
end
