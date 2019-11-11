module ActiveMerchant::Billing::PaywareConnectGateway::AdminActions
  class AddCustomerAndContract < ActiveMerchant::Billing::PaywareConnectGateway::AdminXMLBuilder
    def build
      build_admin_request("ADDON_NEW_CUSTOMER_CONTRACT") do |xml|
        build_customer(xml, options[:customer_id], options)
        build_contract(xml, nil, options[:contract_id], options)
      end
    end
  end
end
