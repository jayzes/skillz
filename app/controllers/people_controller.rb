class PeopleController < ApplicationController

  before_filter :find_person

  PEOPLE_PER_PAGE = 20

  def create
    @person = Person.new(params[:person])
    respond_to do |format|
      if @person.save
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to @person }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @person.destroy
        flash[:notice] = 'Person was successfully destroyed.'        
        format.html { redirect_to people_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'Person could not be destroyed.'
        format.html { redirect_to @person }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @people = Person.paginate(:page => params[:page], :per_page => PEOPLE_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @people }
    end
  end

  def edit
  end

  def new
    @person = Person.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  def update
    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to @person }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_person
    @person = Person.find(params[:id]) if params[:id]
  end

end