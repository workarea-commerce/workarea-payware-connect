module ActiveMerchant
  module Billing
    class PaywareConnectGateway::Actions::Refund < PaywareConnectGateway::XMLBuilder
      attr_reader :cents

      def initialize(cents, merged_options)
        @cents = cents

        super(merged_options)
      end

      def build
        build_credit_request do |xml|
          xml.COMMAND "CREDIT"
          xml.TRANS_AMOUNT "%.2f" % (cents.to_f / 100.0)

          if options[:customer_id] && options[:contract_id]
            xml.RBCUSTOMER_ID options[:customer_id]
            xml.RBCONTRACT_ID options[:contract_id]
          elsif options[:troutd]
            xml.TROUTD options[:troutd]
          else
            raise "Refund require either 1) customer and contract ids or 2) troutd"
          end
        end
      end
    end
  end
end
