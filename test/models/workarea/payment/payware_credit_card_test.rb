require "test_helper"

module Workarea
  class Payment
    class PaywareCreditCardTest < Workarea::TestCase
      def test_partial_number
        payment = Payment.new(
          address: {
            first_name: "eric",
            last_name: "pigeon",
            street: "22 s 4rd st weblinc",
            city: "philadelphia",
            country: Country["US"],
            region: "PA",
            postal_code: "19106"
          }
        )
        payment.set_credit_card(number: "4111111111111111", month: "01", year: "2020", cvv: 111)
        assert payment.credit_card.partial_number.present?
      end

      def test_partial_number_from_saved_card
        profile = create_payment_profile
        saved_card = create_saved_credit_card(profile: profile)

        payment = Payment.new(
          profile: profile,
          address: {
            first_name: "eric",
            last_name: "pigeon",
            street: "22 s 4rd st weblinc",
            city: "philadelphia",
            country: Country["US"],
            region: "PA",
            postal_code: "19106"
          }
        )

        payment.set_credit_card(saved_card_id: saved_card.id)
        assert payment.credit_card.partial_number.present?
      end
    end
  end
end
