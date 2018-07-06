class MoviesController < ApplicationController
  before_action :js_authenticate_user!, only: [:like_movie, :create_comment, :destroy_comment, :update_comment]
  before_action :authenticate_user!, except: [:index, :show, :search_movie]
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :create_comment]
  

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.page(params[:page])  
    # respond_to do |format|
      
    #   format.html {}
    #   format.js {}
    # end
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    @comments = @movie.comments
    p @comments
    if user_signed_in?
      @like = Like.where(user_id: current_user.id, movie_id: params[:id]).first  
    end
    
    

  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)
    @movie.user_id = current_user.id
    
    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def like_movie
    p params
    # 현재 유저와 params에 담긴 movie 간의 좋아요 관계 설정.
    # 만약 현재 로그인한 유저가 이미 좋아요를 눌렀을 경우, 해당 Like 인스턴스 삭제
    # 새로 누른 경우 좋아요 관계 설정
    
    @like = Like.where(user_id: current_user.id, movie_id: params[:movie_id]).first
    p @like
    if @like.nil?
      @like = Like.create(user_id: current_user.id, movie_id: params[:movie_id])

    else
      @like.destroy
    end
      
  end
  
  def create_comment
    @comment = Comment.create(user_id: current_user.id, movie_id: @movie.id, contents: params[:contents])
  end

  def destroy_comment
    @comment = Comment.find(params[:comment_id]).destroy
  end
  
  def update_comment
    @comment = Comment.find(params[:comment_id])
    @comment.update(contents: params[:contents])
  end
  
  
  def search_movie
    respond_to do |format|
      if params[:q].strip.empty?
        
        # 비어있을 때는 아무 응답도 하지 않도록
        format.js { render 'no_content' }
      else
        # params[:q]로 받는 것으로 시작하는 것 중에서 title이 일치하는 것으로 찾는다.
        
        @movies = Movie.where("title LIKE ?", "#{params[:q]}%")
        format.js { render 'search_movie' }
      end
    end
      
    
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end
    
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :genre, :director, :actors, :description, :image_path)
    end
    
    

end
