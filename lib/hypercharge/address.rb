# encoding: UTF-8

module Hypercharge
  # this class prepresents an Address as it occurs as billing_address in
  # Payment's and Transaction's
  class Address

    attr_reader :first_name, :last_name, :address1, :address2,
                :zip_code, :city

    # Returns the value of attribute country_code in ISO 3166
    # http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    attr_reader :country_code

    # Returns the value of attribute state_code in ISO 3166-2
    attr_reader :state_code


    def initialize(params)
      @first_name     = params['first_name']
      @last_name      = params['last_name']
      @address1       = params['address1']
      @address2       = params['address2']
      @zip_code       = params['zip_code']
      @city           = params['city']
      @state_code     = params['state']
      @country_code   = params['country']
    end
  end
end