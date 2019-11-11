module ActiveMerchant::Billing::PaywareConnectGateway::AdminActions
  class AddCustomer < ActiveMerchant::Billing::PaywareConnectGateway::AdminXMLBuilder
    def build
      build_admin_request("ADDON_NEW_CUSTOMER") do |xml|
        build_customer(xml, options[:customer_id], options)
      end
    end
  end
end
