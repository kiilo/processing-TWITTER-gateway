import controlP5.*;

ControlP5 controlP5;

//int myColorBackground = color(0,0,0);
//int sliderValue = 100;
Textfield GetPin;
Button DeauthorizeButton;
Textfield OscRecvPortC5;
Textfield OscDestHostC5;
Textfield OscDestPortC5;
Textfield OscRecvAddressC5;
Textfield OscSendAddressC5;
Textfield TwitterFollowIDsC5;
Textfield TwitterTrackWordsC5;
Textarea ActivityLogTextarea;
int[] LineEnds;
int LineNr;


void SetupControlP5() {
  controlP5 = new ControlP5(this);
  //controlP5.setControlFont(new ControlFont(createFont("Verdana",28,true), 14));

  ActivityLogTextarea = controlP5.addTextarea( "ActivityLog","",16,32,592,240);
  ActivityLogTextarea.setLineHeight(12);
  ActivityLogTextarea.setColor(0xf0f0f0);
  ActivityLogTextarea.enableColorBackground();
  ActivityLogTextarea.setColorBackground(0x0708090a);  
  ActivityLogTextarea.showScrollbar();
  ActivityLogTextarea.moveTo("default");
  ActivityLogAddLine("setup ...");

  OscRecvPortC5 = controlP5.addTextfield("OSC receiving port",232,32,64,20);
  OscRecvPortC5.setAutoClear(false);
  OscRecvPortC5.setColorBackground(color(250,250,250));
  OscRecvPortC5.setColorValue(color(10,10,10));
  OscRecvPortC5.setText(OscRecvPort+" ");
  OscRecvPortC5.moveTo("settings");
  
  
  OscDestHostC5 = controlP5.addTextfield("OSC destination host",16,88,200,20);
  OscDestHostC5.setAutoClear(false);
  OscDestHostC5.setColorBackground(color(250,250,250));
  OscDestHostC5.setColorValue(color(10,10,10));
  OscDestHostC5.setText(OscDestHost+" ");
  OscDestHostC5.moveTo("settings");
  
  OscDestPortC5 = controlP5.addTextfield("OSC destination port",232,88,64,20);
  OscDestPortC5.setAutoClear(false);
  OscDestPortC5.setColorBackground(color(250,250,250));
  OscDestPortC5.setColorValue(color(10,10,10));
  OscDestPortC5.setText(OscDestPort+" ");
  OscDestPortC5.moveTo("settings");
  
  OscRecvAddressC5 = controlP5.addTextfield("OSC receiving address",344,32,200,20);
  OscRecvAddressC5.setAutoClear(false);
  OscRecvAddressC5.setColorBackground(color(250,250,250));
  OscRecvAddressC5.setColorValue(color(10,10,10));
  OscRecvAddressC5.setText(OscRecvAddress+" ");
  OscRecvAddressC5.moveTo("settings");
  
  OscSendAddressC5 = controlP5.addTextfield("OSC sending address",344,88,200,20);
  OscSendAddressC5.setAutoClear(false);
  OscSendAddressC5.setColorBackground(color(250,250,250));
  OscSendAddressC5.setColorValue(color(10,10,10));
  OscSendAddressC5.setText(OscSendAddress+" ");
  OscSendAddressC5.moveTo("settings");
  
  
  TwitterFollowIDsC5 = controlP5.addTextfield("TWITTER follow IDs",16,172,280,20);
  TwitterFollowIDsC5.setAutoClear(false);
  TwitterFollowIDsC5.setColorBackground(color(250,250,250));
  TwitterFollowIDsC5.setColorValue(color(10,10,10));
  String TwitterFollowIDsString = "";
  if (TwitterFollowIDs.length > 0) {
    for (int i = 0 ; i < TwitterFollowIDs.length; i++) {
      TwitterFollowIDsString += String.valueOf(TwitterFollowIDs[i]) + " ";
      }
  }  
  TwitterFollowIDsC5.setText(TwitterFollowIDsString+" ");
  TwitterFollowIDsC5.moveTo("settings");
  
  TwitterTrackWordsC5 = controlP5.addTextfield("TWITTER track words",16,224,280,20);
  TwitterTrackWordsC5.setAutoClear(false);
  TwitterTrackWordsC5.setColorBackground(color(250,250,250));
  TwitterTrackWordsC5.setColorValue(color(10,10,10));
  String TwitterTrackWordsString = "";
  for (int i = 0 ; i < TwitterTrackWords.length; i++) {
    TwitterTrackWordsString += TwitterTrackWords[i] + " ";
  }
  TwitterTrackWordsC5.setText(TwitterTrackWordsString+" ");
  TwitterTrackWordsC5.moveTo("settings");
  
  if (!Authorized) {
    GetPin = controlP5.addTextfield("PIN",160,140,100,20);        //.setCaptionLabel("Enter the PIN(if aviailable) or just hit enter.[PIN]:");
    GetPin.setAutoClear(false);
    GetPin.setColorBackground(color(250,250,250));
    GetPin.setColorValue(color(10,10,10));
    GetPin.valueLabel().setFont(ControlP5.grixel);
    GetPin.moveTo("auth");
  }
  else {
    DeauthorizeButton = controlP5.addButton("deauthorize",255,160,140,100,20);
    DeauthorizeButton.setColorBackground(color(64,164,164));
    DeauthorizeButton.setColorValue(color(10,10,10));
    DeauthorizeButton.moveTo("auth");
  }
  controlP5.draw(); //draw once because SetupIrc needs some seconds
}

/*
void slider(int theColor) {
 myColorBackground = color(theColor);
 println("a slider event. setting background to "+theColor);
 }
 
 void sliderValue(int theColor) {
 myColorBackground = color(theColor);
 println("a sliderValue event. setting background to "+theColor);
 }
 */

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isController()) {
    String CtrlStr = theControlEvent.controller().label();
    String CtrlValueStr = trim(theControlEvent.controller().stringValue());
    if (!CtrlStr.equals("deauthorize")) {
      ((Textfield)theControlEvent.controller()).setText( CtrlValueStr+" " );
    }
    println("controller : "+CtrlStr + " Value : "+ CtrlValueStr); 
    if (CtrlStr.equals("OSC RECEIVING PORT")) {
      OscRecvPort = int(CtrlValueStr);
    } 
    if (CtrlStr.equals("OSC RECEIVING ADDRESS")) {
      OscRecvAddress = CtrlValueStr;
    }
    if (CtrlStr.equals("OSC DESTINATION HOST")) {
      println("SET OSC DESTINATION HOST" + CtrlValueStr);
      OscDestHost = CtrlValueStr;
    }
    if (CtrlStr.equals("OSC DESTINATION PORT")) {
      OscDestPort = int(CtrlValueStr);
    }    
    if (CtrlStr.equals("OSC SENDING ADDRESS")) {
      OscSendAddress = CtrlValueStr;
    }
    if (CtrlStr.equals("TWITTER FOLLOW IDS")) {
      String[] TwitterFollowIDsString = split(CtrlValueStr," ");
      if (TwitterFollowIDsString.length > 0) {
        TwitterFollowIDs = new long[ TwitterFollowIDsString.length ];
        for (int i=0; i < TwitterFollowIDs.length; i++) {
          TwitterFollowIDs[i] = Long.parseLong( TwitterFollowIDsString[i] );
          }
      }
      else { 
        TwitterFollowIDs = new long[0];
      }
    }
    if (CtrlStr.equals("TWITTER TRACK WORDS")) {
      TwitterTrackWords = split(CtrlValueStr," ");      
    }
    SaveProperties();  
  }
  if (theControlEvent.isTab()) {
    println("tab : "+theControlEvent.tab().id()+" / "+theControlEvent.tab().name());
  }
}

void ActivityLogAddLine(String aTextLine) {
  //println(ActivityLogTextarea.text().length());
  while (ActivityLogTextarea.text().length() > 2500) {
    int IndexOfFirstLine = ActivityLogTextarea.text().indexOf("\n");
    if (IndexOfFirstLine > 1) {
      //println( IndexOfFirstLine );
      ActivityLogTextarea.setText(ActivityLogTextarea.text().substring(IndexOfFirstLine+1));
    }
  }
  int length =  aTextLine.replaceAll("[^\\p{ASCII}]","*").length();
  if (length > 12) {length = 12;}
  String TimeStamp = String.valueOf(day())+"."+String.valueOf(month())+"."+String.valueOf(year())+" "+String.valueOf(hour())+":"+String.valueOf(minute())+":"+String.valueOf(second());
  //String aMessage = aTextLine.replaceAll(".[^\\p{ASCII}]","*");
  // !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
  String aMessage = aTextLine.replaceAll("[^A-Za-z !\"#$%&'()*+-,./0123456789:;<=>?@^_`]","*");
  ActivityLogTextarea.setText(ActivityLogTextarea.text()+TimeStamp+" "+aMessage+"\n");
  //ActivityLogTextarea.setText(ActivityLogTextarea.text()+String.valueOf(day())+"."+String.valueOf(month())+"."+String.valueOf(year())+" "+String.valueOf(hour())+":"+String.valueOf(minute())+":"+String.valueOf(second())+" "+"\n");
}

public void PIN(String theText) {
  // receiving text from controller PIN
  pin = theText;
}

public void deauthorize(int clicky) {
// just delete the oAuth plonks
  TwitterAccessToken="";
  TwitterAccessTokenSecret="";
  SaveProperties();
  println("################### RESTART YOUR APP!!! to reflect changes ################");
}



