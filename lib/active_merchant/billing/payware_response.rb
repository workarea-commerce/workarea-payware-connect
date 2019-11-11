module ActiveMerchant
  module Billing
    class Response
      def troutd
        params.fetch("RESPONSE", {})["TROUTD"]
      end
    end
  end
end
