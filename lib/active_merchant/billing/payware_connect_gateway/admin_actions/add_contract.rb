module ActiveMerchant::Billing::PaywareConnectGateway::AdminActions
  class AddContract < ActiveMerchant::Billing::PaywareConnectGateway::AdminXMLBuilder
    def build
      build_admin_request("ADDON_NEW_CONTRACT") do |xml|
        build_contract(xml, options[:customer_id], options[:contract_id], options)
      end
    end
  end
end
