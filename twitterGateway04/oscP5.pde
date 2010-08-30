import oscP5.*;
import netP5.*;

OscP5 oscP5;
String OscDestHost;
int OscDestPort;
int OscRecvPort;
String OscRecvAddress;
String OscSendAddress;
NetAddress OscDestination;
boolean OscSanitize;

void SetupOscP5() {
  oscP5 = new OscP5(this, OscRecvPort);
  OscDestination = new NetAddress(OscDestHost, OscDestPort);
  // following line just works for ONE symbol sen from puredata
  //oscP5.plug(this,"OscToIrc", OscRecvAddress);
}

// OscToIrc
// OscToIrc
void OscToTwitter(String OscToTwitterMessage) {
  ActivityLogAddLine("OSC RECV "+OscRecvAddress+" "+OscToTwitterMessage);
  try {
    Status status = twitterOut.updateStatus(OscToTwitterMessage);
  }
  catch (TwitterException ex) {
    println("EXCEPTIONAL ERROR EXCEPTION");
  }
  ActivityLogAddLine("TWITTER SEND "+OscToTwitterMessage);
}


void oscEvent(OscMessage aOscMessage) {
  // following lines build a string from the OSC message
  if (aOscMessage.checkAddrPattern(OscRecvAddress) == true ) {   // react only to our osc.address.recv setting
    String OscToTwitterMessage = "";
    for(int i=0; i < aOscMessage.typetag().length(); i++) {
      switch ( aOscMessage.typetag().charAt(i) ) { 
      case 's':
        OscToTwitterMessage += aOscMessage.get(i).stringValue()+" ";
        break;
      case 'i':
        OscToTwitterMessage += str(aOscMessage.get(i).intValue())+" ";
        break;
      case 'f':
        OscToTwitterMessage += str(aOscMessage.get(i).floatValue())+" ";
        break;
      default:
        println("ERROR unsupported osc typtag");
        ActivityLogAddLine("ERROR unsupported osc typtag");
        break;
      }
    }
    OscToTwitterMessage = trim(OscToTwitterMessage);
    OscToTwitter(OscToTwitterMessage);
  }
}


