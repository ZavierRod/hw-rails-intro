class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings
    ratings_param = params[:ratings]

    if ratings_param.nil? || ratings_param.empty?
      selected_ratings = @all_ratings
    else
      selected_ratings = ratings_param.keys
    end

    sort_param = params[:sort_by]

    sort_types = ['title', 'release_date']
    if sort_param.nil? || sort_param.empty? || !sort_types.include?(sort_param)
      selected_sort = nil
    else
      selected_sort = sort_param
    end

    if (ratings_param.nil? || ratings_param.empty?) && (sort_param.nil? || sort_param.empty?)
      if (!session[:ratings].nil? && !session[:ratings].empty?) || (!session[:sort_by].nil? && !session[:sort_by].empty?)
        session_ratings = session[:ratings]
        if session_ratings.nil? || session_ratings.empty?
          safe_ratings = @all_ratings
        else
          safe_ratings = session_ratings & @all_ratings
          if safe_ratings.empty?
            safe_ratings = @all_ratings
          end
        end

        session_sort = session[:sort_by]
        if session_sort.nil? || session_sort.empty? || !sort_types.include?(session_sort)
          safe_sort = nil
        else
          safe_sort = session_sort
        end
        redirect_params = {}
        redirect_params[:ratings] = safe_ratings.map { |r| [r, '1']}.to_h
        if !safe_sort.nil?
          redirect_params[:sort_by] = safe_sort
        end
        redirect_to movies_path(redirect_params)
        return
      end
    end

    session[:ratings] = selected_ratings
    session[:sort_by] = selected_sort
    @ratings_to_show = selected_ratings
    @sort_by = selected_sort
    @ratings_hash = @ratings_to_show.map { |r| [r, '1']}.to_h

    relation = Movie.with_ratings(@ratings_to_show)
    if @sort_by.nil?
      @movies = relation
    else
      @movies = relation.order(@sort_by => :asc)
    end
    return
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
