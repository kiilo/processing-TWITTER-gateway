import twitter4j.*;
import java.lang.Exception;

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

PrintWriter output;


void SetupTwitter() {
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
  output = createWriter("log.txt"); 


  StatusListener twitterIn = new StatusListener() {
    public void onStatus(Status status) {
      double Longitude;
      double Latitude;
      GeoLocation GeoLoc = status.getGeoLocation();
      if (GeoLoc != null) {
        //println("YES got a location");
        Longitude = GeoLoc.getLongitude();
        Latitude = GeoLoc.getLatitude();
      }
      else {
        Longitude = 0;
        Latitude = 0; 
      }
      println( TimeStamp()+"\t" + Latitude + "\t" + Longitude + "\t"+ status.getUser().getScreenName() + "\t" + status.getText());
      output.println(TimeStamp()+"\t" + Latitude + "\t" + Longitude + "\t"+ status.getUser().getScreenName() + "\t" + status.getText());
      output.flush();
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


void TwitterToOsc(String TwitterSender, String TwitterMessage) {
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


void AuthorizeTwitter () 
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

void GetRequestToken () 
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

void GetAccessToken ()
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


