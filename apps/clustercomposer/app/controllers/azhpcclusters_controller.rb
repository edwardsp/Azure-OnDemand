class AzhpcclustersController < ApplicationController
  before_action :update_azhpcclusters, only: [:index, :show, :destroy]

  # GET /azhpcclusters
  # GET /azhpcclusters.json
  def index
    @default_template = Template.default
    @templates = Template.all

    @selected_id = session[:selected_id]
    session[:selected_id] = nil
    #@azhpcclusters = Azhpccluster.preload(:azhpcclusters)
    @azhpcclusters = Azhpccluster.all
  end

  def update_azhpcclusters
    # get all of the active azhpcclusters
    #fails no active
    #Azhpccluster.preload(:azhpcclusters).active.to_a.each(&:update_status!)
  end

  # GET /azhpcclusters/1
  # GET /azhpcclusters/1.json
  def show
    set_azhpccluster
    @azhpccluster = Azhpccluster.find(params[:id])
    @azhpccluster.jobs.last.update_status! unless @azhpccluster.jobs.last.nil?
  end

  # GET /azhpcclusters/new
  def new
    @azhpccluster = Azhpccluster.new
    @templates = Template.all
  end

  def new_from_path
    @azhpccluster = Azhpccluster.new
    if params[:path]
      @azhpccluster = Azhpccluster.new_from_path(params[:path])
    end
  end

  # GET /azhpcclusters/1/edit
  def edit
    set_azhpccluster
  end

  # POST /azhpcclusters
  # POST /azhpcclusters.json
  def create
    @templates = Template.all
    @azhpccluster = Azhpccluster.new(azhpccluster_params)

    respond_to do |format|
      if @azhpccluster.save
        session[:selected_id] = @azhpccluster.id
        format.html { redirect_to azhpcclusters_url, notice: 'Cluster was successfully saved.' }
        format.json { render :show, status: :created, location: @azhpccluster}
      else
        format.html { render :new }
        format.json { render json: @azhpccluster.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /azhpcclusters/create_from_path
  # POST /azhpcclusters/create_from_path.json
  def create_from_path
    @azhpccluster = Azhpccluster.new_from_path(azhpccluster_params[:staging_template_dir])
    @azhpccluster.name = azhpccluster[:name] unless azhpccluster_params[:name].blank?

    # validate path we are copying from. safe_path is a boolean, error contains the error string if false
    copy_safe, error = Filesystem.new.validate_path_is_copy_safe(@azhpccluster.staging_template_dir.to_s)
    @azhpccluster.errors.add(:staging_template_dir, error) unless copy_safe

    # If the azhpccluster passes validation but a name hasn't been assigned, set the name to the inputted path
    if @azhpccluster.errors.empty? && @azhpccluster.name.blank?
      @azhpccluster.name = @azhpccluster.staging_template_dir
    end

    respond_to do |format|
      if @azhpccluster.errors.empty? && @azhpccluster.save
        format.html { redirect_to azhpcclusters_url, notice: 'Cluster was successfully created.' }
        format.json { render :show, status: :created, location: @azhpccluster }
      else
        format.html { render :new_from_path }
        format.json { render json: @azhpccluster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /azhpcclusters/1
  # PATCH/PUT /azhpcclusters/1.json
  def update
    set_azhpccluster

    respond_to do |format|
      if @azhpccluster.update(azhpccluster_params)
        session[:selected_id] = @azhpccluster.id
        format.html { redirect_to azhpcclusters_path, notice: 'Cluster was successfully updated.' }
        format.json { render :show, status: :ok, location: @azhpccluster }
      else
        format.html { render :edit }
        format.json { render json: @azhpccluster.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_azhpccluster
  #  @azhpcluster = Azhpccluster.preload(:jobs).find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def azhpccluster_params
    params.require(:azhpccluster).permit!
  end

end