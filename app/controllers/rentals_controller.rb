require 'date'

class RentalsController < ApplicationController

  def create
    if params[:movie_id].nil? || params[:customer_id].nil? || (Movie.find_by(id: params[:movie_id])).nil? || (Customer.find_by(id: params[:customer_id])).nil?
      render json: {ok: false}, status: :not_found
    else
      movie = Movie.rentable_movie?(params[:movie_id])
      customer = Customer.find_by(id: params[:customer_id])
      today = Date.today

      rental_data = {
        movie_id: (params[:movie_id]),
        customer_id: (params[:customer_id]),
        check_out_date: today.to_s,
        due_date: (today + 7).to_s
      }

      if movie
        rental = Rental.new(rental_data)
      end

      if movie && rental.save
        Movie.decrement(movie)
        Customer.add_movie(customer)

        render json: {id: rental.id}, status: :ok
      else
        if rental.nil?
          "no available_inventory for movie"
        elsif rental.errors.nil?
          error_messages = "cannot specify"
        else
          error_messages = rental.errors
        end
        render json: {ok: false, errors: error_messages}, status: :bad_request
      end
    end
  end


  def update
    if params[:movie_id].nil? || (Movie.find_by(id: params[:movie_id])).nil? || params[:customer_id].nil? || (Customer.find_by(id: params[:customer_id])).nil?
      render json: {ok: false}, status: :bad_request
    else
      rental_movie = Movie.returnable_movie?(Movie.find_by(id: params[:movie_id]))
      customer = Customer.find_by(id: params[:customer_id])

      if rental_movie
        Movie.increment(rental_movie)
        Customer.remove_movie(customer)
        render json: {id: rental_movie.id}, status: :ok
      else
        render json: {ok: false}, status: :bad_request
      end
    end
  end

  private

  def rental_params
    return params.permit(:movie_id, :customer_id)
  end
end
