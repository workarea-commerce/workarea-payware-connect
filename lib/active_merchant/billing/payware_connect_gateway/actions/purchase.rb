module ActiveMerchant
  module Billing
    class PaywareConnectGateway::Actions::Purchase < PaywareConnectGateway::XMLBuilder
      attr_reader :cents

      def initialize(cents, merged_options)
        @cents = cents

        super(merged_options)
      end

      def build
        build_credit_request do |xml|
          xml.COMMAND "SALE"
          xml.TRANS_AMOUNT "%.2f" % (cents.to_f / 100.0)
          xml.PRESENT_FLAG "1"

          if options[:invoice_number]
            xml.INVOICE options[:invoice_number]
          end

          if options[:force]
            xml.FORCE_FLAG "true"
          end

          if options[:billing_address]
            address = options[:billing_address]
            xml.CARDHOLDER "#{address.first_name} #{address.last_name}"
            xml.CUSTOMER_STREET address.street[0..19] # max length of this field is 20 characters
            xml.CUSTOMER_CITY address.city
            xml.CUSTOMER_STATE address.region
            xml.CUSTOMER_ZIP address.postal_code
          end

          if options[:customer_id] && options[:contract_id]
            xml.RBCUSTOMER_ID options[:customer_id]
            xml.RBCONTRACT_ID options[:contract_id]

          elsif options[:credit_card]
            credit_card = options[:credit_card]
            xml.ACCT_NUM credit_card.number
            xml.CVV2 credit_card.verification_value

            month = credit_card.month
            month = month.to_s.rjust(2, "0")
            xml.EXP_MONTH month
            xml.EXP_YEAR credit_card.year.to_s[-2, 2] # last two digits of year

          elsif options[:troutd]
            xml.REF_TROUTD options[:troutd]

          else
            raise "Purchase requires either 1) customer and contract ids, 2) credit card, 3) troutd from previous authorization"
          end
        end
      end
    end
  end
end
