class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[ show edit update destroy like ]

  # GET /tweets
  def index
    @tweets = Tweet.order(created_at: :desc)
  end

  # GET /tweets/1
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets
  def create
    @tweet = Tweet.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        if session[:authored_ids]
          session[:authored_ids] << @tweet.id
        else
          session[:authored_ids] = [@tweet.id]
        end
        format.html { redirect_to @tweet, notice: "Tweet was successfully created." }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1
  def update
    if @tweet.update(tweet_params)
      redirect_to @tweet, notice: "Tweet was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /tweets/1
  def destroy
    if session[:authored_ids].nil? || !session[:authored_ids].include?(@tweet.id)
      respond_to do |format|
        format.html { redirect_to @tweet, alert: "You are not allowed to delete this tweet", status: :see_other }
        format.json { head :forbidden }
      end
    else
      @tweet.destroy!
      respond_to do |format|
        format.html { redirect_to tweets_path, notice: "Tweet was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      end
    end
  end

  #LIKE /tweets/:id/like
  def like
    session[:liked_ids] ||= []                      
    unless session[:liked_ids].include?(@tweet.id) 
      @tweet.likes += 1
      @tweet.save
      session[:liked_ids] << @tweet.id             
    end
    redirect_to root_path                           
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tweet_params
      params.expect(tweet: [ :author, :content ])
    end
end
