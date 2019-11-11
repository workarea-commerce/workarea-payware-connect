module ActiveMerchant
  module Billing
    class BogusPaywareConnectGateway < ActiveMerchant::Billing::BogusGateway
      def authorize(cents, credit_card_or_troutd, options = {})
        credit_card_or_troutd = credit_card_or_troutd[:credit_card] || credit_card_or_troutd[:troutd]
        case normalize(credit_card_or_troutd)
        when /1$/, ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
          successful_auth_response(cents)
        when /2$/
          failure_response(cents)
        else
          raise Error, error_message(credit_card_or_troutd)
        end
      end

      def purchase(cents, credit_card_or_troutd, options = {})
        credit_card_or_troutd = credit_card_or_troutd[:credit_card] || credit_card_or_troutd[:troutd]
        case normalize(credit_card_or_troutd)
        when /1$/, ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
          successful_purchase_response(cents)
        when /2$/
          failure_response(cents)
        else
          raise Error, error_message(credit_card_or_troutd)
        end
      end

      def store(credit_card, options = {})
        authorize(0, credit_card: credit_card, amount: "0.0")
      end

      private

        def failure_response(money)
          Response.new(
            false,
            FAILURE_MESSAGE,
            { authorized_amount: money, error: FAILURE_MESSAGE },
            { test: true, error_code: STANDARD_ERROR_CODE[:processing_error] }
          )
        end

        def successful_auth_response(cents)
          result = "APPROVED"
          troutd = ActiveMerchant::Billing::BogusGateway::AUTHORIZATION

          params = {
            "RESPONSE" => {
              "AUTH_CODE"          => "094073",
              "AVS_CODE"           => "Y",
              "BATCH_NUM"          => "329001",
              "CLIENT_ID"          => "7769900010001",
              "COMMAND"            => "PRE_AUTH",
              "CTROUTD"            => "24",
              "CVV2_CODE"          => "Y",
              "INTRN_SEQ_NUM"      => "4666700",
              "INVOICE"            => "4666700",
              "PAYMENT_MEDIA"      => "VISA",
              "PAYMENT_TYPE"       => "CREDIT",
              "PY_RESP_CODE"       => "A",
              "REFERENCE"          => "00000020",
              "RESPONSE_CODE"      => "A",
              "RESPONSE_TEXT"      => result,
              "RESULT"             => result,
              "RESULT_CODE"        => "5",
              "TERMINATION_STATUS" => "SUCCESS",
              "TRANS_AMOUNT"       => "%.2f" % (cents.to_f / 100.0),
              "TRANS_DATE"         => "2013.11.25",
              "TRANS_SEQ_NUM"      => "30",
              "TRANS_TIME"         => "15:13:17",
              "TROUTD"             => troutd
            }
          }

          ActiveMerchant::Billing::Response.new(
            true,
            "APPROVED",
            params,
            test: true,
            authorization: params["RESPONSE"]["TROUTD"],
            cvv_result: params["RESPONSE"]["CVV2_CODE"],
            avs_result: { code: params["RESPONSE"]["AVS_CODE"] }
          )
        end

        def successful_purchase_response(cents)
          result = "APPROVED"
          troutd = ActiveMerchant::Billing::BogusGateway::AUTHORIZATION

          params = {
            "RESPONSE" => {
              "AUTH_CODE"          => "094073",
              "AVS_CODE"           => "Y",
              "BATCH_NUM"          => "329001",
              "CLIENT_ID"          => "7769900010001",
              "COMMAND"            => "SALE",
              "CTROUTD"            => "24",
              "CVV2_CODE"          => "Y",
              "INTRN_SEQ_NUM"      => "4666700",
              "INVOICE"            => "4666700",
              "PAYMENT_MEDIA"      => "VISA",
              "PAYMENT_TYPE"       => "CREDIT",
              "PY_RESP_CODE"       => "A",
              "REFERENCE"          => "00000020",
              "RESPONSE_CODE"      => "A",
              "RESPONSE_TEXT"      => result,
              "RESULT"             => result,
              "RESULT_CODE"        => "5",
              "TERMINATION_STATUS" => "SUCCESS",
              "TRANS_AMOUNT"       => "%.2f" % (cents.to_f / 100.0),
              "TRANS_DATE"         => "2013.11.25",
              "TRANS_SEQ_NUM"      => "30",
              "TRANS_TIME"         => "15:13:17",
              "TROUTD"             => troutd
            }
          }

          ActiveMerchant::Billing::Response.new(
            true,
            "APPROVED",
            params,
            test: true,
            authorization: params["RESPONSE"]["TROUTD"],
            cvv_result: params["RESPONSE"]["CVV2_CODE"],
            avs_result: { code: params["RESPONSE"]["AVS_CODE"] }
          )
        end
    end
  end
end
