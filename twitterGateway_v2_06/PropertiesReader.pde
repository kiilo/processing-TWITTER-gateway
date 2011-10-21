P5Properties props;

// this function reads our properties file
void SetupP5Properties() {
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

  boolean getBooleanProperty(String id, boolean defState) {
    return boolean(getProperty(id,""+defState));
  }

  int getIntProperty(String id, int defVal) {
    return int(getProperty(id,""+defVal));
  }

  float getFloatProperty(String id, float defVal) {
    return float(getProperty(id,""+defVal));
  }

  String getStringProperty(String id, String defVal) {
    return trim(getProperty(id,""+defVal));
  }
}


void SaveProperties() {
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

