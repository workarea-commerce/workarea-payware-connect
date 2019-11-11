require "test_helper"

module ActiveMerchant
  module Billing
    class PaywareConnectGatewayTest < Workarea::TestCase
      def test_add_customer
        customer_id = generate_id
        response = VCR.use_cassette("payware/add_customer") do
          gateway.add_customer(
            customer_id: customer_id,
            email: email,
            billing_address: billing_address
          )
        end

        assert(response.success?)
        assert_equal("SUCCESS", response.message)
        assert_equal("1", response.params["AdminResponse"]["Status_Code"])
      end

      def test_add_contract
        customer_id = generate_id
        contract_id = generate_id

        response = VCR.use_cassette("payware/add_contract") do
          gateway.add_customer(
            customer_id: customer_id,
            email: email,
            billing_address: billing_address
          )
          gateway.add_contract(
            customer_id: customer_id,
            contract_id: contract_id,
            credit_card: credit_card
          )
        end

        assert(response.success?)
        assert_equal("SUCCESS", response.message)
        assert_equal("1", response.params["AdminResponse"]["Status_Code"])
      end

      def test_authorize_customer_and_contract
        customer_id = generate_id
        contract_id = generate_id

        response = VCR.use_cassette("payware/authorize_customer_and_contract") do
          gateway.add_customer(
            customer_id: customer_id,
            email: email,
            billing_address: billing_address
          )
          gateway.add_contract(
            customer_id: customer_id,
            contract_id: contract_id,
            credit_card: credit_card
          )
          gateway.authorize(
            1000,
            customer_id: customer_id,
            contract_id: contract_id
          )
        end

        assert(response.success?)
        assert_equal("TAS584", response.authorization)
        assert_equal("10.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
        assert_equal("95860", response.troutd)
      end

      def test_authorize_credit_card
        response = VCR.use_cassette("payware/authorize_credit_card") do
          gateway.authorize(
            1000,
            credit_card: credit_card,
            billing_address: billing_address
          )
        end

        assert(response.success?)
        assert(response.authorization.present?)
        assert_equal("10.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
        assert(response.troutd.present?)
      end

      def test_authorize_zero_dollar_credit_card
        response = VCR.use_cassette("payware/authorize_for_0_credit_card") do
          gateway.authorize(
            0,
            credit_card: credit_card,
            billing_address: billing_address
          )
        end

        assert(response.success?)
        assert(response.authorization.present?)
        assert(response.troutd.present?)
        assert_equal("0.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
      end

      def test_authorize_for_troutd
        response = VCR.use_cassette("payware/authorize_troutd") do
          first_response = gateway.authorize(
            1000,
            credit_card: credit_card,
            billing_address: billing_address
          )

          troutd = first_response.troutd
          gateway.authorize(
            500,
            troutd: troutd,
            billing_address: billing_address
          )
        end

        assert(response.success?)
        assert(response.authorization.present?)
        assert(response.troutd.present?)
        assert_equal("5.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
      end

      def test_authorize_for_zero_dollar_with_troutd
        response = VCR.use_cassette("payware/authorize_for_0_troutd") do
          first_response = gateway.authorize(
            1000,
            credit_card: credit_card,
            billing_address: billing_address
          )

          troutd = first_response.troutd
          gateway.authorize(
            0,
            troutd: troutd,
            billing_address: billing_address
          )
        end

        assert(response.success?)
        assert(response.authorization.present?)
        assert(response.troutd.present?)
        assert_equal("0.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
      end

      def test_refund
        customer_id = generate_id
        contract_id = generate_id

        response = VCR.use_cassette("payware/refund") do
          gateway.add_customer(
            customer_id: customer_id,
            email: email,
            billing_address: billing_address
          )
          gateway.add_contract(
            customer_id: customer_id,
            contract_id: contract_id,
            credit_card: credit_card
          )
          gateway.authorize(
            1000,
            customer_id: customer_id,
            contract_id: contract_id
          )
          gateway.refund(
            1000,
            customer_id: customer_id,
            contract_id: contract_id
          )
        end

        assert(response.success?)
        assert_equal("10.00", response.params["RESPONSE"]["TRANS_AMOUNT"])
      end

      def test_refund_troutd
        VCR.use_cassette("payware/refund_troutd") do
          authorization = gateway.authorize(
            1000,
            credit_card: credit_card,
            billing_address: billing_address
          )

          troutd = authorization.params["RESPONSE"]["TROUTD"]

          refund = gateway.refund(
            1000,
            troutd: troutd
          )

          assert(refund.success?)
        end
      end

      def test_capture
        VCR.use_cassette("payware/capture") do
          authorization = gateway.authorize(
            1000,
            credit_card: credit_card,
            billing_address: billing_address
          )

          troutd = authorization.params["RESPONSE"]["TROUTD"]

          capture = gateway.capture(1000, troutd)

          assert(capture.success?)
        end
      end

      def test_void_authorization
        VCR.use_cassette("payware/void_authorization") do
          authorization = gateway.authorize(
            100,
            credit_card: credit_card,
            billing_address: billing_address
          )

          assert(authorization.success?)

          troutd = authorization.params["RESPONSE"]["TROUTD"]

          void = gateway.void(troutd)

          assert(void.success?)
        end
      end

      private

        def credit_card_params
          {
            first_name:         "Mike",
            last_name:          "Dalton",
            month:              12,
            year:               Time.now.year + 1,
            verification_value: "999"
          }
        end

        def credit_card
          params = credit_card_params.merge(
            number: "4111111111111111",
            brand:  "visa"
          )
          ActiveMerchant::Billing::CreditCard.new(params)
        end

        def billing_address
          Workarea::Address.new(
            first_name:   "Mike",
            last_name:    "Dalton",
            street:       "22 S. 3rd St.",
            city:         "Philadelphia",
            region:       "PA",
            postal_code:  "19406",
            phone_number: "215-555-5555"
          )
        end

        def gateway
          ActiveMerchant::Billing::PaywareConnectGateway.new(
            client_id: "17270300010001",
            login: "apiuser",
            password: "6GHMg7ur",
            merchant_key: "49BC6225-4B49-4585-8D34-07DCA05CF3937FD6C525-8AEE-4916-BEEC-BDB",
            test: true
          )
        end

        def email
          "mdalton@weblinc.com"
        end

        def generate_id
          (1 + rand(100000)).to_s
        end
    end
  end
end
