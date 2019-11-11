# Use these commands in the console to log all of the requests and responses for validation

gateway = Workarea.config.gateways.credit_card

card = OpenStruct.new(number: "4111111111111111", verification_value: "900", month: "12", year: "2018")
billing_address = OpenStruct.new(first_name: "Mark", last_name: "Platt", street: "916 Bartram Ave.", city: "Collingdale", region: "PA", postal_code: "19023")

Rails.logger.debug("***Authorize(Void)***")
response = gateway.authorize(100.to_m, credit_card: card, billing_address: billing_address)

Rails.logger.debug("***Void***")
gateway.void(response.params["RESPONSE"]["TROUTD"])

Rails.logger.debug("***Authorize(Capture)***")
response = gateway.authorize(101.to_m, credit_card: card, billing_address: billing_address)

Rails.logger.debug("***Capture***")
gateway.capture(101.to_m, response.params["RESPONSE"]["TROUTD"])

Rails.logger.debug("***Authorize(First)***")
gateway.authorize(104.to_m, credit_card: card, billing_address: billing_address, invoice_number: "123")
Rails.logger.debug("***Authorize(Dupe)***")
gateway.authorize(104.to_m, credit_card: card, billing_address: billing_address, invoice_number: "123")
Rails.logger.debug("***Authorize(Force)***")
gateway.authorize(104.to_m, credit_card: card, billing_address: billing_address, force: "true", invoice_number: "123")
