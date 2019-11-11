module ActiveMerchant
  module Billing
    class PaywareConnectGateway::XMLBuilder
      def initialize(merged_options)
        @client_id    = merged_options[:client_id]
        @merchant_key = merged_options[:merchant_key]
        @login        = merged_options[:login]
        @password     = merged_options[:password]
        @options      = merged_options
      end

      def build
        raise NotImplemented
      end

      private

        attr_reader :options, :client_id, :merchant_key, :login, :password

        def build_credit_request
          xml = Builder::XmlMarkup.new
          xml.TRANSACTION do
            xml.FUNCTION_TYPE "PAYMENT"
            xml.PAYMENT_TYPE "CREDIT"
            xml.CLIENT_ID(client_id)
            xml.MERCHANTKEY(merchant_key)
            xml.USER_ID(login)
            xml.USER_PW(password)
            yield xml
          end
          xml.target!
        end
    end
  end
end
