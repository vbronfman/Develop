<<<<<<< HEAD
import SOAPpy

#
# <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cms="http://cms.orange.com/">
   #<soapenv:Header/>
   #   <soapenv:Body>
   #   <cms:getConnection>
   #   <!--Optional:-->
   #  <user>IFBL</user>
   #  <!--Optional:-->
   #  <password>IFBL</password>
   #  <id>222222</id>
   #  </cms:getConnection>
   #  </soapenv:Body>
   #  </soapenv:Envelope>
#
class RequestData :
    def __init__ ( self, login, password ) :
        self.login = login
        self.password = password

def main () :
    #http://vmcmstst2:6672/WsEe/RoomOffer
    SOAPclient = SOAPpy.WSDL.Proxy( r'http://vmcmstst2:6672/WsEe/RoomOffer' )
    print client.say_hello( name = 'getConnection' )
  #  print client.login( request = RequestData( "roinet", "123" ) )

if __name__ == '__main__' :
=======
import SOAPpy

#
# <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cms="http://cms.orange.com/">
   #<soapenv:Header/>
   #   <soapenv:Body>
   #   <cms:getConnection>
   #   <!--Optional:-->
   #  <user>IFBL</user>
   #  <!--Optional:-->
   #  <password>IFBL</password>
   #  <id>222222</id>
   #  </cms:getConnection>
   #  </soapenv:Body>
   #  </soapenv:Envelope>
#
class RequestData :
    def __init__ ( self, login, password ) :
        self.login = login
        self.password = password

def main () :
    #http://vmcmstst2:6672/WsEe/RoomOffer
    SOAPclient = SOAPpy.WSDL.Proxy( r'http://vmcmstst2:6672/WsEe/RoomOffer' )
    print client.say_hello( name = 'getConnection' )
  #  print client.login( request = RequestData( "roinet", "123" ) )

if __name__ == '__main__' :
>>>>>>> e55f97114d0da06a25cf60393f67b0e16521bd92
    main()