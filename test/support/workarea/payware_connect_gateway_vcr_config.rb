module Workarea
  module PaywareConnectGatewayVCRConfig
    def self.included(test)
      super
      test.setup :setup_gateway
      test.teardown :reset_gateway
    end

    def setup_gateway
      @_old_gateway = Workarea.config.gateways.credit_card
      Workarea.config.gateways.credit_card = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        client_id: "17270300010001",
        login: "apiuser",
        password: "6GHMg7ur",
        merchant_key: "49BC6225-4B49-4585-8D34-07DCA05CF3937FD6C525-8AEE-4916-BEEC-BDB",
        test: true
      )
    end

    def reset_gateway
      Workarea.config.gateways.credit_card = @_old_gateway
    end
  end
end
