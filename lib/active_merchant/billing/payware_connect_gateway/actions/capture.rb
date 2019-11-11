module ActiveMerchant
  module Billing
    class PaywareConnectGateway < ActiveMerchant::Billing::Gateway
      module Actions
        class Capture < PaywareConnectGateway::XMLBuilder
          attr_reader :cents, :authorization

          def initialize(cents, authorization, merged_options)
            @cents = cents
            @authorization = authorization

            super(merged_options)
          end

          def build
            build_credit_request do |xml|
              xml.COMMAND "COMPLETION"
              xml.TROUTD authorization
              xml.TRANS_AMOUNT "%.2f" % (cents.to_f / 100.0)
            end
          end
        end
      end
    end
  end
end
