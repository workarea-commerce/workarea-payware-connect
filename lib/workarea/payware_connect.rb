require "workarea"

require "workarea/payware_connect/engine"
require "workarea/payware_connect/version"

require "active_merchant/billing/payware_connect_gateway"
require "active_merchant/billing/bogus_payware_connect_gateway"

module Workarea
  module PaywareConnect
    def self.auto_configure_gateway
      secrets = Rails.application.secrets.payware_connect

      if secrets.present?
        secrets = secrets.deep_symbolize_keys

        self.gateway = ActiveMerchant::Billing::PaywareConnectGateway.new(
          client_id:    secrets[:client_id],
          login:        secrets[:login],
          password:     secrets[:password],
          merchant_key: secrets[:merchant_key],
          test:         secrets.fetch(:test, true)
        )
      else
        self.gateway = ActiveMerchant::Billing::BogusPaywareConnectGateway.new
      end

      if ENV["HTTP_PROXY"].present? && gateway.present?
        parsed = URI.parse(ENV["HTTP_PROXY"])
        ActiveMerchant::Billing::PaywareConnectGateway.proxy_address = parsed.host
        ActiveMerchant::Billing::PaywareConnectGateway.proxy_port = parsed.port
      end
    end

    def self.gateway=(gateway)
      Workarea.config.gateways.credit_card = gateway
    end

    def self.gateway
      Workarea.config.gateways.credit_card
    end
  end
end
