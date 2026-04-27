class MoviesController < ApplicationController

  def index
    @movies = Movie.all
    
    if params[:rating].present?
      @movies = @movies.where(rating: params[:rating].to_i)
    end
    
    # Determine sort order based on sort_by parameter
    if params[:sort_by].present?
      case params[:sort_by]
      when 'title'
        @title_header = params[:sort_order] == 'desc' ? '↓' : '↑'
        @movies = @movies.order(title: params[:sort_order] == 'desc' ? :desc : :asc)
      when 'release_date'
        @release_date_header = params[:sort_order] == 'desc' ? '↓' : '↑'
        @movies = @movies.order(release_date: params[:sort_order] == 'desc' ? :desc : :asc)
      end
    else
      @movies = @movies.order(created_at: :desc)
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to movies_path, notice: "Movie created successfully."
    else
      render :new
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    @movie = Movie.find(params[:id])
    if @movie.update(movie_params)
      redirect_to movies_path, notice: "Movie updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path, notice: "Movie deleted successfully."
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

end