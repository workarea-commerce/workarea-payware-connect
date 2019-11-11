Workarea Payware Connect
================================================================================

Payware Connect plugin for the Workarea platform.

Change Log
--------------------------------------------------------------------------------
Version 1.1.6 (10/13/2016)

   Changed URLs used by the Payment Gatway
    - old production URL: https://ipcharge.net/IPCHAPI/RH.aspx
    - new production URL: https://prod1.ipcharge.net/ipchapi/rh.aspx

Getting Started
--------------------------------------------------------------------------------
NOTES
-----
**(9/15/15) Only Pre-auth, Completion, and Void are supported and validated as of v0.9.4.**
**(10/21/15) Storing cards in user accounts is broken pending verification of business requirements v0.9.5.**
IF INTEGRATING WITH MACH VALIDATION IS UNNECESSARY.
SEE VALIDATION LETTER AND WORKSHEET FOR MORE INFO.

Revalidation is necessary if any of these change:
1. Business type
2. Transaction type supported
3. Code Changes that may affect Transactions or reports
4. Change in Processor
5. Report type supported
6. New Device Supported

The file lib\validation.rb can be used in the console to generate the necessary xml and output to the development.log
-----


Gateways
--------------------------------------------------------------------------------
Unless keys are provided in the secrets.yml file the Payware Connect engine will
use a bogus gateway.

If you want to use the live gateway you must include the following keys in your
secrets.yml:

    :payware_connect:
      :client_id:
      :login:
      :password:
      :merchant_key:
      :test: # if using sandbox

If the above keys are provided the gateway will be automatically configured. For
more details on this implementation. Test is optional and will default to true.

Workarea Platform Documentation
--------------------------------------------------------------------------------

See [http://guides.weblinc.com](http://guides.weblinc.com) for Workarea platform documentation.

Copyright & Licensing
--------------------------------------------------------------------------------

Copyright WebLinc 2016. All rights reserved.

For licensing, contact sales@weblinc.com.
