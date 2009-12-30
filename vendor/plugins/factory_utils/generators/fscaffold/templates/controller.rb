class <%= controller_class_name %>Controller < ApplicationController
  # GET /<%= plural_name %>
<%- if options[:xml] -%>
  # GET /<%= plural_name %>.xml
<%- end -%>
  def index
    @<%= plural_name %> = <%= model_name %>.paginate :page => params[:page], :per_page => 20 

    respond_to do |format|
      format.html # index.html.erb
<%- if options[:xml] -%>
      format.xml  { render :xml => @<%= plural_name %> }
<%- end -%>
    end
  end

  # GET /<%= plural_name %>/1
<%- if options[:xml] -%>
  # GET /<%= plural_name %>/1.xml
<%- end -%>
  def show
    @<%= file_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb 
<%- if options[:xml] -%>
      format.xml  { render :xml => @<%= file_name %> }
<%- end -%>
    end
  end

  # GET /<%= plural_name %>/new
<% if options[:xml] -%> 
  # GET /<%= plural_name %>/new.xml
<% end -%>
  def new
    @<%= file_name %> = <%= model_name %>.new

    respond_to do |format|
      format.html # new.html.erb
<% if options[:xml] -%>
      format.xml  { render :xml => @<%= file_name %> } 
<% end -%>
    end
  end

  # GET /<%= plural_name %>/1/edit
  def edit
    @<%= file_name %> = <%= model_name %>.find(params[:id])
  end

  # POST /<%= plural_name %>
<% if options[:xml] -%>
  # POST /<%= plural_name %>.xml
<% end -%>
  def create
    @<%= file_name %> = <%= model_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= model_name %> was successfully created.'
        format.html { redirect_to( <%= plural_route_path %>_path ) }
<% if options[:xml] -%>
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
<% end -%>
      else
        format.html { render :action => "new" }
<% if options[:xml] -%>
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
<% end -%>
      end
    end
  end

  # PUT /<%= plural_name %>/1
<% if options[:xml] -%>
  # PUT /<%= plural_name %>/1.xml
<% end -%>
  def update
    @<%= file_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= model_name %> was successfully updated.'
        format.html { redirect_to(edit_<%= singular_route_path %>_path(@<%= singular_name %>)) }
<% if options[:xml] -%>
        format.xml  { head :ok }
<% end -%>
      else
        format.html { render :action => "edit" }
<% if options[:xml] -%>
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity } 
<% end -%>
      end
    end
  end

  # DELETE /<%= plural_name %>/1
<% if options[:xml] -%>
  # DELETE /<%= plural_name %>/1.xml
<% end -%>
  def destroy
    @<%= file_name %> = <%= model_name %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= plural_route_path %>_url) }
<% if options[:xml] -%>
      format.xml  { head :ok }
<% end -%>
    end
  end
end
