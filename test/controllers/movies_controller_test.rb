require "test_helper"

describe MoviesController do

  describe "index" do
    it "is a real working route" do
      get movies_url
      must_respond_with :success
    end

    it "returns json" do
      get movies_url
      response.header['Content-Type'].must_include 'json'
    end

    it "returns an Array" do
      get movies_url

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "returns all of the movies" do
      get movies_url

      body = JSON.parse(response.body)
      body.length.must_equal Movie.count
    end

    it "returns movies with exactly the required fields" do
      # unsure of order for keys...doesn't matter?
      keys = %w(title overview release_date inventory id)

      get movies_url
      body = JSON.parse(response.body)
      body.each do |movie|
        movie.keys.sort.must_equal keys.sort
      end
    end
  end

  describe "show" do
    # This bit is up to you!
    it "can get a movie" do
      get movie_path(movies(:two).id)
      must_respond_with :success
    end

    it "responds with not_found if get a movie given invalid id" do
      movie = movies(:two)
      movie.destroy
      get movie_path(movie.id)
      must_respond_with :not_found
    end
  end

  describe "create" do
    let(:movie_data) {
      {
        title: "Pirates of the Caribbean",
        overview: "The ocean's black pearl saves and perishes",
        release_date: "2000",
        inventory: 3
      }
    }

    it "Creates a new movie" do

      proc{
        post movies_url, params: { movie: movie_data }
      }.must_change "Movie.count", 1
      must_respond_with :success
    end

    it "returns a bad request for a bad params data" do
      movie_data[:name] = nil

      proc{
        post movies_url, params: { movie: movie_data }
      }.must_change "Movie.count", 0
      must_respond_with :bad_request
      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "errors"
      body["errors"].must_include "title"
    end

  end
end
