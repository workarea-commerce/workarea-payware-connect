module ActiveMerchant
  module Billing
    class PaywareConnectGateway < ActiveMerchant::Billing::Gateway
      require "active_merchant/billing/payware_response"
      require "active_merchant/billing/payware_connect_gateway/xml_builder"
      require "active_merchant/billing/payware_connect_gateway/actions/authorize"
      require "active_merchant/billing/payware_connect_gateway/actions/capture"
      require "active_merchant/billing/payware_connect_gateway/actions/purchase"
      require "active_merchant/billing/payware_connect_gateway/actions/refund"
      require "active_merchant/billing/payware_connect_gateway/actions/void"
      require "active_merchant/billing/payware_connect_gateway/admin_xml_builder"
      require "active_merchant/billing/payware_connect_gateway/admin_actions/add_contract"
      require "active_merchant/billing/payware_connect_gateway/admin_actions/add_customer"
      require "active_merchant/billing/payware_connect_gateway/admin_actions/add_customer_and_contract"
      require "active_merchant/billing/payware_connect_gateway/admin_actions/update_contract"
      require "active_merchant/billing/payware_connect_gateway/admin_actions/update_customer"

      self.ssl_version = :TLSv1_2
      self.test_url = "https://cert.api.vfipayna.com/IPCHAPI/RH.ASPX"
      self.live_url = "https://api.vfipayna.com/IPCHAPI/RH.ASPX"

      cattr_accessor :test_admin_url, :live_admin_url
      self.test_admin_url = "https://cert1.ipcharge.net/ipcadminapi/RH.ipc"
      self.live_admin_url = "https://prod1.ipcharge.net/ipcadminapi/RH.ipc"

      def initialize(options = {})
        requires!(options, :login, :password)
        super
      end

      def authorize(cents, command_options = {})
        commit(Actions::Authorize.new(cents, command_options.merge(options)).build)
      end

      def store(credit_card, command_options = {})
        command_options = command_options.merge(credit_card: credit_card)
        commit(Actions::Authorize.new(0, command_options.merge(options)).build)
      end

      def refund(cents, command_options = {})
        commit(Actions::Refund.new(cents, command_options.merge(options)).build)
      end

      def purchase(cents, command_options = {})
        commit(Actions::Purchase.new(cents, command_options.merge(options)).build)
      end

      def capture(cents, authorization, command_options = {})
        commit(Actions::Capture.new(cents, authorization, command_options.merge(options)).build)
      end

      def void(authorization, command_options = {})
        commit(Actions::Void.new(authorization, command_options.merge(options)).build)
      end

      def add_customer(command_options = {})
        requires!(command_options, :customer_id)
        commit_admin(AdminActions::AddCustomer.new(command_options.merge(options)).build)
      end

      def update_customer(command_options = {})
        requires!(command_options, :customer_id)
        commit_admin(AdminActions::UpdateCustomer.new(command_options.merge(options)).build)
      end

      def add_customer_and_contract(command_options = {})
        requires!(command_options, :customer_id, :contract_id)
        commit_admin(AdminActions::AddCustomerAndContract.new(command_options.merge(options)).build)
      end

      def add_contract(command_options = {})
        requires!(command_options, :customer_id, :contract_id, :credit_card)
        commit_admin(AdminActions::AddContract.new(command_options.merge(options)).build)
      end

      def update_contract(command_options = {})
        requires!(command_options, :customer_id, :contract_id, :credit_card)
        commit_admin(AdminActions::UpdateContract.new(command_options.merge(options)).build)
      end

      private

        def commit_admin(request)
          url = test? ? test_admin_url : live_admin_url
          response = perform_api_call(request, url)

          success = response["AdminResponse"]["Status_Code"] == "1"
          message = response["AdminResponse"]["Message"]
          params = response

          ActiveMerchant::Billing::Response.new(
            success,
            message,
            params,
            test: test?
          )
        end

        SUCCESS_CODES = ["APPROVED", "CAPTURED", "VOIDED", "VERIFIED"]

        def commit(request)
          url = test? ? test_url : live_url
          response = perform_api_call(request, url)

          success = SUCCESS_CODES.include?(response["RESPONSE"]["RESULT"])
          message = response["RESPONSE"]["RESPONSE_TEXT"]
          params = response

          response_options = {
            authorization: response["RESPONSE"]["AUTH_CODE"],
            test: test?
          }

          if response["RESPONSE"]["AVS_CODE"].present?
            response_options.merge!(avs_result: { code: response["RESPONSE"]["AVS_CODE"] })
          end

          if response["RESPONSE"]["CVV2_CODE"].present?
            response_options.merge!(cvv_result: response["RESPONSE"]["CVV2_CODE"])
          end

          ActiveMerchant::Billing::Response.new(success, message, params, response_options)
        end

        def perform_api_call(request, url)
          ::Rails.logger.debug(request) if ::Rails.env.development?

          raw_response = ssl_post(url, request, "Content-Type" => "text/xml")

          ::Rails.logger.debug(raw_response) if ::Rails.env.development?

          raw_response.gsub!(/[\n\r]/, "")
          Hash.from_xml(raw_response)
        end
    end
  end
end
