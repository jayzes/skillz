class SkillsController < ApplicationController

  before_filter :find_skill

  SKILLS_PER_PAGE = 20

  def create
    @skill = Skill.new(params[:skill])
    respond_to do |format|
      if @skill.save
        flash[:notice] = 'Skill was successfully created.'
        format.html { redirect_to skills_path }
        format.xml  { render :xml => @skill, :status => :created, :location => @skill }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skill.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @skill.destroy
        flash[:notice] = 'Skill was successfully destroyed.'        
        format.html { redirect_to skills_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'Skill could not be destroyed.'
        format.html { redirect_to @skill }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @skills = Skill.paginate(:page => params[:page], :per_page => SKILLS_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @skills }
    end
  end

  def edit
  end

  def new
    @skill = Skill.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @skill }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @skill }
    end
  end

  def update
    respond_to do |format|
      if @skill.update_attributes(params[:skill])
        flash[:notice] = 'Skill was successfully updated.'
        format.html { redirect_to skills_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skill.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_skill
    @skill = Skill.find(params[:id]) if params[:id]
  end

end