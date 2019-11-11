class ActiveMerchant::Billing::PaywareConnectGateway::AdminXMLBuilder
  def initialize(merged_options)
    @client_id = merged_options[:client_id]
    @merchant_key = merged_options[:merchant_key]
    @login = merged_options[:login]
    @password = merged_options[:password]
    @options = merged_options
  end

  def build
    raise NotImplemented
  end

  def build_customer(xml, customer_id, options)
    xml.CUSTOMER("Merchant_Customer_ID" => customer_id) do
      if options[:billing_address]
        build_address(xml, options)
      else
        xml.First_Name options[:first_name]
        xml.Last_Name options[:last_name]
      end
    end
  end

  def build_address(xml, options)
    address = options[:billing_address]
    xml.Company_Name address.company
    xml.First_Name address.first_name
    xml.Last_Name address.last_name
    xml.Address_1 address.street
    xml.Address_2 address.street_2
    xml.City address.city
    xml.Zip address.postal_code
    xml.Pri_Phone address.phone_number
    xml.Pri_Email options[:email]
  end

  def build_contract(xml, customer_id, contract_id, options)
    xml.CONTRACT do
      xml.Merchant_Customer_ID(customer_id) if customer_id
      xml.Merchant_Contract_ID(contract_id)

      credit_card = options[:credit_card]
      build_credit_card(xml, credit_card)
    end
  end

  def build_credit_card(xml, credit_card)
    brand = credit_card.brand.try(:upcase)
    brand =
      if brand == "MASTER"
        "MC"
      else
        brand
      end

    month = credit_card.month
    month = month.to_s.rjust(2, "0")

    xml.Card_Type brand if brand
    xml.Pri_Account_Number credit_card.number if credit_card.number.present?
    xml.Pri_Exp_Month month
    xml.Pri_Exp_Year credit_card.year.to_s[-2, 2] # last two digits of year
    xml.fAlt_Payment(false) # "This signals the system to use the alternate card until such time that it is switched to the primary card. This value must be included and defaulted to false"
  end

  private

    attr_reader :options, :client_id, :merchant_key, :login, :password

    def build_admin_request(command_type)
      xml = Builder::XmlMarkup.new
      xml.AdminRequest do
        build_admin_header(xml, command_type)

        xml.AdminBody do
          xml.HEADER do
            build_header(xml)
          end

          xml.DETAIL do
            xml.RECORD do
              yield xml
            end
          end
        end
      end
      xml.target!
    end

    def build_admin_header(xml, command_type)
      xml.AdminHeader do
        xml.RequestType("IPCRB_ADMIN")
        xml.FunctionType("ADDON")
        xml.CommandType(command_type)
      end
    end

    def build_header(xml)
      xml.Client_ID(client_id)
      xml.MERCHANTKEY(merchant_key)
      xml.USERID(login)
      xml.USERPWD(password)
    end
end
