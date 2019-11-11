module ActiveMerchant
  module Billing
    class PaywareConnectGateway::Actions::Void < PaywareConnectGateway::XMLBuilder
      attr_reader :authorization

      def initialize(authorization, merged_options)
        @authorization = authorization

        super(merged_options)
      end

      def build
        build_credit_request do |xml|
          xml.COMMAND "VOID"
          xml.TROUTD authorization
        end
      end
    end
  end
end
