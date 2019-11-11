module ActiveMerchant::Billing::PaywareConnectGateway::AdminActions
  class UpdateContract < ActiveMerchant::Billing::PaywareConnectGateway::AdminXMLBuilder
    def build
      build_admin_request("ADDON_UPDATE_CONTRACT") do |xml|
        build_contract(xml, options[:customer_id], options[:contract_id], options)
      end
    end
  end
end
