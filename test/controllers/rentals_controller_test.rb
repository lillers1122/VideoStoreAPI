require "test_helper"

describe RentalsController do
  describe "create" do
    describe "valid rental requests" do
      it "it creates a rental record" do
        rental_count = Rental.count

        customer_movie_info = {
          customer_id: customers(:one).id,
          movie_id: movies(:one).id
        }
        post rental_path(customer_movie_info)

        must_respond_with :success
        Rental.count.must_equal (rental_count + 1)
      end

      it "returns json" do
        customer_movie_info = {
          customer_id: customers(:one).id,
          movie_id: movies(:one).id
        }
        post rental_path(customer_movie_info)

        response.header['Content-Type'].must_include 'json'
      end

      it "returns the correct rental" do
        customer_movie_info = {
          customer_id: customers(:one).id,
          movie_id: movies(:one).id
        }
        post rental_path(customer_movie_info)

        body = JSON.parse(response.body)
        body.length.must_equal 1
        body["id"].must_equal Rental.last.id
      end

      it "decrements the movie's available_inventory" do
        test_movie = movies(:one)
        initial_inventory = test_movie.available_inventory

        customer_movie_info = {
          customer_id: (customers(:one)).id,
          movie_id: test_movie.id
        }

        post rental_path(customer_movie_info)
        Movie.find(test_movie.id).available_inventory.must_equal (initial_inventory - 1)
      end

      it "decrements the movie's available_inventory when available_inventory is 1" do
        # update the fixture to include that it must have its inventory of 1 for testing this edge case
        test_movie = movies(:five)
        initial_inventory = test_movie.available_inventory

        customer_movie_info = {
          customer_id: (customers(:one)).id,
          movie_id: test_movie.id
        }

        post rental_path(customer_movie_info)
        Movie.find(test_movie.id).available_inventory.must_equal (initial_inventory - 1)
      end

      it "increments customer's checked out count" do
        movie = movies(:two)
        customer = customers(:one)
        customer.movies_checked_out_count.must_equal 0
        data = {movie_id: movie.id, customer_id: customer.id}

        post rental_path(data)
        customer.reload
        customer.movies_checked_out_count.must_equal 1
      end
    end

    describe "Invalid rental responses" do
      it "catches rental requests for unavailable movies" do
        rental_count = Rental.count

        customer_movie_info = {
          customer_id: customers(:one).id,
          movie_id: movies(:three)
        }
        post rental_path(customer_movie_info)

        must_respond_with :bad_request
        Rental.count.must_equal rental_count
      end

      it "create rental returns a status of not_found for invalid movie id" do
        test_movie = movies(:one)

        customer_movie_info = {
          customer_id: nil,
          movie_id: test_movie.id
        }

        post rental_path(customer_movie_info)
        must_respond_with :not_found
      end

      it "create rental returns a status of not_found for invalid customer id" do

        customer_movie_info = {
          customer_id: (customers(:one)).id,
          movie_id: nil
        }

        post rental_path(customer_movie_info)
        must_respond_with :not_found
      end

      it "create rental for invalid customer id does not decrement available_inventory" do
        test_movie = movies(:one)

        initial_inventory = test_movie.available_inventory

        customer_movie_info = {
          customer_id: nil,
          movie_id: test_movie.id
        }

        post rental_path(customer_movie_info)
        Movie.find(test_movie.id).available_inventory.must_equal (initial_inventory)
      end

      it "cannot rent movie with available_inventory of 0, :bad_request response, does not decrement available_inventory" do
        test_movie = movies(:three)
        test_movie.available_inventory.must_equal 0

        customer_movie_info = {
          customer_id: customers(:one).id,
          movie_id: test_movie.id
        }

        post rental_path(customer_movie_info)
        must_respond_with :bad_request
        Movie.find(test_movie.id).available_inventory.must_equal 0
      end
    end
  end

  describe "update" do
    describe "valid update requests" do

      it "returns json" do
        movie = movies(:two)

        post rental_update_path(
          {movie_id: movie.id}
        )
        response.header['Content-Type'].must_include 'json'
      end

      it "returns the correct rental's movie id" do
        movie = movies(:two)
        customer = customers(:two)
        data = {movie_id: movie.id, customer_id: customer.id}

        post rental_update_path(data)

        body = JSON.parse(response.body)
        body["id"].must_equal movie.id
      end

      it "increments the movie's available_inventory" do
        movie = movies(:two)
        customer = customers(:two)
        data = {movie_id: movie.id, customer_id: customer.id}

        starting_available_inventory = movie.available_inventory

        post rental_update_path(data)

        Movie.find(movie.id).available_inventory.must_equal (starting_available_inventory + 1)
      end

      it "decrement customer's checked out count" do
        movie = movies(:two)
        customer = customers(:one)
        customer.movies_checked_out_count.must_equal 0
        data = {movie_id: movie.id, customer_id: customer.id}

        post rental_path(data)
        customer.reload
        customer.movies_checked_out_count.must_equal 1

        post rental_update_path(data)
        customer.reload
        customer.movies_checked_out_count.must_equal 0
      end
    end

    describe "Invalid update requests" do
      it "update rental returns a status of bad_request for nil movie id value" do
        rental_count = Rental.count

        data = {
          movie_id: nil}

          post rental_update_path(data)

          must_respond_with :bad_request
          Rental.count.must_equal rental_count
        end

        it "update rental returns a status of bad_request for invalid movie id value" do
          rental_count = Rental.count

          data = {
            movie_id: -999}

            post rental_update_path(data)

            must_respond_with :bad_request
            Rental.count.must_equal rental_count
          end
# write a test that allows anyone to return a checkedout movie ...doesn't have to be returned with a customer id in the params
it " " do

end
          it "cannot update rental movie with available_inventory == inventory" do

            rental_count = Rental.count

            movie = movies(:four)
            movie.available_inventory.must_equal movie.inventory

            initial_inventory = movie.available_inventory

            data = {
              movie_id: movie.id
            }

            post rental_update_path(data)

            must_respond_with :bad_request
            Rental.count.must_equal rental_count
            movie.available_inventory.must_equal initial_inventory
          end
        end
      end

    end
