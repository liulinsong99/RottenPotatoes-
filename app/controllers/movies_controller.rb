class MoviesController < ApplicationController

  def show
    logger.info "****Print on show****"
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def api(params)
    logger.info "****Print on api****"
    logger.info params['ratings']

    if params['ratings'] == nil and params['sorting'] == nil
      return
    end

    if params['ratings'] == nil
      session['ratings'] = @all_ratings
    else
      session['ratings'] = params['ratings'].keys
    end

    session['sorting'] = params['sorting']
  end

  def index
    logger.info "****Print on index****"
    logger.info params
    @all_ratings = ['G','PG','PG-13','R']

    if params != {"controller"=>"movies", "action"=>"index"}
      api(params)
    end

    if session['ratings'] == nil
      session['ratings'] = @all_ratings
    end
    @ratings_to_show = session['ratings']
    
    if session['sorting'] == nil
      session['sorting'] = nil
    end
    @sorting = session['sorting']


    if params['ratings'] == nil and params['sorting'] == nil
      new_params = {}
      new_params['ratings'] = Hash[@ratings_to_show.map {|rating| [rating,'1']}]
  
      if @sorting != nil
        new_params['sorting'] = @sorting
      end
      logger.info new_params

      redirect_to movies_path(new_params)
      return

    end


    @movies = Movie.with_ratings(@ratings_to_show, @sorting)
  end

  def new
    logger.info "****Print on new****"
    # default: render 'new' template
  end

  def create
    logger.info "****Print on create****"
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    logger.info "****Print on edit****"
    @movie = Movie.find params[:id]
  end

  def update
    logger.info "****Print on update****"
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    logger.info "****Print on destroy****"
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    logger.info "****Print on movie_params****"
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
