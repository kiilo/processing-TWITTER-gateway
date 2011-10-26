import processing.core.*; 
import processing.xml.*; 

import twitter4j.*; 
import java.lang.Exception; 
import controlP5.*; 
import oscP5.*; 
import netP5.*; 

import twitter4j.conf.*; 
import twitter4j.internal.async.*; 
import twitter4j.internal.org.json.*; 
import netP5.*; 
import twitter4j.internal.logging.*; 
import twitter4j.json.*; 
import twitter4j.internal.util.*; 
import controlP5.*; 
import twitter4j.management.*; 
import twitter4j.auth.*; 
import oscP5.*; 
import twitter4j.api.*; 
import twitter4j.util.*; 
import twitter4j.internal.http.*; 
import twitter4j.*; 
import twitter4j.internal.json.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class twitterGateway_v2_06 extends PApplet {

PImage backgr;

public void setup() {
  size(640, 320, P2D);
  smooth();
  noStroke();
  frameRate(25);
  backgr = loadImage("backgr.png");
  //background(255,204,0);
  background(backgr);
  SetupP5Properties();
  SetupControlP5();
  SetupOscP5();
  if (Authorized) {
    println("YES associated to a twitter account");
    SetupTwitter();
  }
  //SaveProperties();  
}

public void draw() {
  if (!Authorized) {
    AuthorizeTwitter();
  }
  //PImage b = loadImage("backgr.png");
  background(backgr);
  controlP5.draw();
  //delay(20);
}


/*

This processing application is: coded by 
AUTHOR kiilo (Tobias Hoffmann) kiilo@kiilo.org 10/2011 Montreal
LICENCE http://creativecommons.org/licenses/by-nc/3.0/ 



version 2.0 - originalk  version coded for playaround workshop NTUA 2010 Taipei Taiwan
http://playaround.cc

########

Libraries used and included:

########

oscP5/netP5 - http://www.sojamo.de/libraries/oscP5/index.html - AUTHOR Andreas Schlegel
controlP5 - http://www.sojamo.de/libraries/controlP5/ - AUTHOR Andreas Schlegel

########

twitter4j - http://twitter4j.org - AUTHOR Yusuke Yamamoto

# LICENCE for twitter4j
Copyright 2007 Yusuke Yamamoto

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
Distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/
P5Properties props;

// this function reads our properties file
public void SetupP5Properties() {
  try {
    props = new P5Properties();
    // load a configuration from a file inside the data folder
    props.load(createInput("gateway.properties"));
    OscRecvPort = props.getIntProperty("osc.receiving.port",8000);
    OscDestHost = props.getStringProperty("osc.destination.host","localhost");
    OscDestPort = props.getIntProperty("osc.destination.port",9000);
    OscRecvAddress = props.getStringProperty("osc.address.recv","/toTwitter");
    OscSendAddress = props.getStringProperty("osc.address.send","/fromTwitter");
    // read TWITTER config part
    TwitterUsername = props.getStringProperty("twitter.username","");
    TwitterPassword = props.getStringProperty("twitter.password","");
    TwitterConsumerKey = props.getStringProperty("twitter.ConsumerKey","");
    TwitterConsumerSecret = props.getStringProperty("twitter.ConsumerSecret","");
    TwitterAccessToken = props.getStringProperty("twitter.AccessToken","");
    TwitterAccessTokenSecret = props.getStringProperty("twitter.AccessTokenSecret","");
    println(TwitterAccessToken.length());
    if (TwitterAccessToken.length() < 1) {
      Authorized = false;
      println("not authorized");
    }
    else {
      Authorized = true;
    }
    
    String[] TwitterFollowIDsString = split(props.getStringProperty("twitter.followIDs","69362660")," ");
    if (TwitterFollowIDsString.length > 0) {
      TwitterFollowIDs = new long[ TwitterFollowIDsString.length ];
      for (int i=0; i<TwitterFollowIDs.length; i++) {
        TwitterFollowIDs[i] = Long.parseLong( TwitterFollowIDsString[i] );
      }
    }
    else { 
      TwitterFollowIDs = new long[0];
    }
    
    TwitterTrackWords = split(props.getStringProperty("twitter.trackwords","playaround")," ");
    //props.close();
    
  }

catch(IOException e) {
  println("couldn't read config file..."+e.getMessage());
}
}

/**
 * simple convenience wrapper object for the standard
 * Properties class to return pre-typed numerals
 */
class P5Properties extends Properties {

  public boolean getBooleanProperty(String id, boolean defState) {
    return PApplet.parseBoolean(getProperty(id,""+defState));
  }

  public int getIntProperty(String id, int defVal) {
    return PApplet.parseInt(getProperty(id,""+defVal));
  }

  public float getFloatProperty(String id, float defVal) {
    return PApplet.parseFloat(getProperty(id,""+defVal));
  }

  public String getStringProperty(String id, String defVal) {
    return trim(getProperty(id,""+defVal));
  }
}


public void SaveProperties() {
    try {
        Properties props = new Properties();
        props.setProperty("osc.receiving.port", ""+OscRecvPort);
        
        props.setProperty("osc.destination.host", ""+OscDestHost);
        props.setProperty("osc.destination.port", ""+OscDestPort);
        
        props.setProperty("osc.address.recv", OscRecvAddress);
        props.setProperty("osc.address.send", OscSendAddress);
        
        //props.setProperty("twitter.username", TwitterUsername);
        //props.setProperty("twitter.password", TwitterPassword);
        props.setProperty("twitter.ConsumerKey", TwitterConsumerKey);
        props.setProperty("twitter.ConsumerSecret", TwitterConsumerSecret);
        props.setProperty("twitter.AccessToken", TwitterAccessToken);
        props.setProperty("twitter.AccessTokenSecret", TwitterAccessTokenSecret);
        
        String TwitterFollowIDsString = "";
        
        if (TwitterFollowIDs.length > 0) {
          for (int i = 0 ; i < TwitterFollowIDs.length; i++) {
            TwitterFollowIDsString += String.valueOf(TwitterFollowIDs[i]) + " ";
          }
        } 
               
        props.setProperty("twitter.followIDs", TwitterFollowIDsString);
        
        String TwitterTrackwordsString = "";
        for (int i = 0 ; i < TwitterTrackWords.length; i++) {
          TwitterTrackwordsString += TwitterTrackWords[i] + " ";
        }
        props.setProperty("twitter.trackwords", TwitterTrackwordsString);
        
        
        //File f = new File("config.properties");
        //OutputStream out = new FileOutputStream( f );
        props.store(createOutput("gateway.properties"), " TWITTER gateway configuration");
        println("NEW propeties written");
    }
    catch (Exception e ) {
        e.printStackTrace();
    }
}




//TwitterConnectStream twitterIn;
Twitter twitterOut;
//AccessToken accessToken;
//OAuthAuthorization TwitterOAuthAuthorization;
String TwitterUsername; 
String TwitterPassword;
String TwitterConsumerKey;
String TwitterConsumerSecret;
String TwitterAccessToken;
String TwitterAccessTokenSecret;
long[]  TwitterFollowIDs;
String[] TwitterTrackWords;
boolean Authorized = false;
boolean SplitMessages = false;

Twitter twitter;
int AuthStatus = 1;
String pin = "";
RequestToken requestToken = null;
AccessToken accessToken = null;


public void SetupTwitter() {
  //twitterIn = new TwitterConnectStream();
  //accessToken = new AccessToken(TwitterAccessToken, TwitterAccessTokenSecret);
  //TwitterOAuthAuthorization.setOAuthAccessToken(accessToken);
  //TwitterOAuthAuthorization = new OAuthAuthorization(conf);
  //TwitterOAuthAuthorization.setOAuthConsumer(TwitterConsumerKey, TwitterConsumerSecret);
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setDebugEnabled(true)
    .setOAuthConsumerKey(TwitterConsumerKey)
      .setOAuthConsumerSecret(TwitterConsumerSecret)
        .setOAuthAccessToken(TwitterAccessToken)
          .setOAuthAccessTokenSecret(TwitterAccessTokenSecret);
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitterOut = tf.getInstance();
  //  try {
  //  twitterOut.updateStatus("Hello World!");
  //  }
  //  catch (TwitterException ex) {
  //    println(ex);
  //  }
  ActivityLogAddLine("twitter connector ready");


  StatusListener twitterIn = new StatusListener() {
    public void onStatus(Status status) {
      System.out.println("@" + status.getUser().getScreenName() + " - " + status.getText());
      TwitterToOsc(status.getUser().getScreenName(), status.getText());
    }

    public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
      System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
    }

    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
      System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
    }

    public void onScrubGeo(long userId, long upToStatusId) {
      System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
    }

    public void onException(Exception ex) {
      println("CAUGHT in the ACT: " + ex);
    }
  };

  ConfigurationBuilder cbIn = new ConfigurationBuilder();
  cbIn.setDebugEnabled(true)
    .setOAuthConsumerKey(TwitterConsumerKey)
      .setOAuthConsumerSecret(TwitterConsumerSecret)
        .setOAuthAccessToken(TwitterAccessToken)
          .setOAuthAccessTokenSecret(TwitterAccessTokenSecret);

  TwitterStreamFactory ts = new TwitterStreamFactory(cbIn.build());
  TwitterStream twitterStream = ts.getInstance();
  twitterStream.addListener(twitterIn);

  // filter() method internally creates a thread which manipulates TwitterStream and calls these adequate listener methods continuously.
  FilterQuery twitterFilter = new FilterQuery(0, TwitterFollowIDs, TwitterTrackWords);
  twitterStream.filter(twitterFilter);
}


public void TwitterToOsc(String TwitterSender, String TwitterMessage) {
  //TwitterSender = trim(TwitterSender.replaceAll("[^\\p{ASCII}]","*"));
  //TwitterMessage = trim(TwitterMessage.replaceAll("[^\\p{ASCII}]","*"));
  OscMessage SendOscMessage = new OscMessage(OscSendAddress);
  SendOscMessage.add(TwitterSender);
  //SendOscMessage.add(TwitterMessage);
  String[] OscMessageArguments = {""};
  if (SplitMessages == false) {
    OscMessageArguments[0] = TwitterMessage;
    SendOscMessage.add(OscMessageArguments[0]);
  }
  else {
    OscMessageArguments = split(TwitterMessage, ' ');
    for(int i=0; i < OscMessageArguments.length; i++) {
      try
      {
        float f = Float.valueOf(OscMessageArguments[i].trim()).floatValue();
        SendOscMessage.add(f);
      }
      catch (NumberFormatException nfe)
      {
        SendOscMessage.add(OscMessageArguments[i]);
      }

      //SendOscMessage.add(OscMessageArguments[i]);
    }
  }
  oscP5.send(SendOscMessage, OscDestination);
  ActivityLogAddLine("OSC SEND " + OscSendAddress + " " + TwitterSender + " " + TwitterMessage);
}


public void AuthorizeTwitter () 
{
  //controlP5.draw();
  switch (AuthStatus)
  {
  case 1: 
    GetRequestToken();
    AuthStatus = 2;
    break;

  case 2: 
    // Wait for pin
    if(pin.length() > 0) 
    {
      GetAccessToken();
      AuthStatus = 3;
    }
    break;

  case 3: 
    println("########### PLEASE COPY TO CONFIG ###########");
    println("twitter.AccessToken="+TwitterAccessToken);
    println("twitter.AccessTokenSecret="+TwitterAccessTokenSecret);
    controlP5.window(this).activateTab("auth");
    SaveProperties();
    try 
    {
      props.store(new FileOutputStream("../config.pde"), "configuration in comments to USE processing IDE for editing DONT REMOVE");
    } 
    catch (IOException ex) 
    {
      ex.printStackTrace();
    }
    //props.save();
    AuthStatus = 4;
    break;

  case 4: 
    // Now Twitter could setup
    SetupTwitter();
    AuthStatus = 5;
    Authorized = true;
    break;

  default:
    println("CAUGHT IN THE ACT this should NEVER EVER HAPPEN");
    break;
  }
}

public void GetRequestToken () 
{
  twitter = new TwitterFactory().getInstance();
  twitter.setOAuthConsumer(TwitterConsumerKey, TwitterConsumerSecret);
  try 
  {
    requestToken = twitter.getOAuthRequestToken();
  }
  catch (TwitterException ex) 
  {
    println(ex);
  }
  println("Open the following URL and grant access to your account:");
  println(requestToken.getAuthorizationURL());
  link(requestToken.getAuthorizationURL());
}

public void GetAccessToken ()
{
  //AccessToken accessToken = null;
  while (null == accessToken) {     
    //}
    //catch (TwitterException ex) {
    //  println(ex);
    //}
    println("requestToken "+requestToken);
    println("pin " + pin);
    
    try {
      if(pin.length() > 0) {
        accessToken = twitter.getOAuthAccessToken(requestToken, pin);
      }
      else {
        accessToken = twitter.getOAuthAccessToken();
      }
      TwitterAccessToken = accessToken.getToken();
      TwitterAccessTokenSecret = accessToken.getTokenSecret();
      
    } 
    catch (TwitterException te) {
      if(401 == te.getStatusCode()) {
        println("Unable to get the access token.");
      }
      else {
        te.printStackTrace();
      }
    }
  }
}



/* configuration in comments to USE processing IDE for editing DONT REMOVE 

CONFIG moved to config.properties

*/


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


public void SetupControlP5() {
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

public void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isController()) {
    String CtrlStr = theControlEvent.controller().label();
    String CtrlValueStr = trim(theControlEvent.controller().stringValue());
    if (!CtrlStr.equals("deauthorize")) {
      ((Textfield)theControlEvent.controller()).setText( CtrlValueStr+" " );
    }
    println("controller : "+CtrlStr + " Value : "+ CtrlValueStr); 
    if (CtrlStr.equals("OSC RECEIVING PORT")) {
      OscRecvPort = PApplet.parseInt(CtrlValueStr);
    } 
    if (CtrlStr.equals("OSC RECEIVING ADDRESS")) {
      OscRecvAddress = CtrlValueStr;
    }
    if (CtrlStr.equals("OSC DESTINATION HOST")) {
      println("SET OSC DESTINATION HOST" + CtrlValueStr);
      OscDestHost = CtrlValueStr;
    }
    if (CtrlStr.equals("OSC DESTINATION PORT")) {
      OscDestPort = PApplet.parseInt(CtrlValueStr);
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

public void ActivityLogAddLine(String aTextLine) {
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






OscP5 oscP5;
String OscDestHost;
int OscDestPort;
int OscRecvPort;
String OscRecvAddress;
String OscSendAddress;
NetAddress OscDestination;

public void SetupOscP5() {
  oscP5 = new OscP5(this, OscRecvPort);
  OscListener GatewayOscListener = new OscListener();
  oscP5.addListener(GatewayOscListener);  
  OscDestination = new NetAddress(OscDestHost, OscDestPort);
  // following line just works for ONE symbol sen from puredata
  //oscP5.plug(this,"OscToIrc", OscRecvAddress);
}




class OscListener implements OscEventListener {

  public void oscEvent(OscMessage aOscMessage) {
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
      //println(OscToTwitterMessage);
      OscToTwitter(OscToTwitterMessage);
    }
  }

  public void oscStatus(OscStatus theStatus) {
    println("osc status : "+theStatus.id());
  }
}

// OscTo ...
// OscToTwitter
public void OscToTwitter(String OscToTwitterMessage) {
  ActivityLogAddLine("OSC RECV "+OscRecvAddress+" "+OscToTwitterMessage);
  try { 
    if (twitterOut.getAuthorization().isEnabled()) {
      Status status = twitterOut.updateStatus(OscToTwitterMessage);
      System.out.println("Successfully updated the status to [" + status.getText() + "].");
    }
    else {
      println("ERROR Check authorisation!");
    }
  }
  catch (TwitterException ex) {
    println(ex);
  }
  ActivityLogAddLine("TWITTER SEND "+OscToTwitterMessage);
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "twitterGateway_v2_06" });
  }
}
