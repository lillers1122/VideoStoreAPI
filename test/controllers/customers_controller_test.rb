require "test_helper"

describe CustomersController do
  describe "index" do
    it "is a real working route" do
      get customers_url
      must_respond_with :success
    end

    it "returns json" do
      get customers_url
      response.header['Content-Type'].must_include 'json'
    end

    it "returns an Array" do
      get customers_url

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "returns all of the customers" do
      get customers_url

      body = JSON.parse(response.body)
      body.length.must_equal Customer.count
    end

    # not needed to check individual keys/attributes just confirm it is an instance of customer..ie .must be kind of customer
    it "customers must have requisite info" do
      keys = %w(id name phone postal_code registered_at movies_checked_out_count)
      get customers_url
      body = JSON.parse(response.body)
      body.each do |customer|
        customer.keys.sort.must_equal keys.sort
      end
    end

    it "works with no customers" do
      Customer.destroy_all

      get customers_url
      must_respond_with :success
    end

  end
end
