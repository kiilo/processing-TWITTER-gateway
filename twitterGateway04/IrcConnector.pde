import twitter4j.*;
import java.lang.Exception;

TwitterConnectStream twitterIn;
Twitter twitterOut;
String TwitterUsername; 
String TwitterPassword;
int[]  TwitterFollowIDs;
String[] TwitterTrackWords;

void SetupTwitter() {
  twitterIn = new TwitterConnectStream();
  twitterOut = new TwitterFactory().getInstance( TwitterUsername, TwitterPassword);
  ActivityLogAddLine("twitter connector ready");
}

public class TwitterConnectStream implements StatusListener {
  /**
   * Main entry of this application.
   * @param args String[] TwitterID TwitterPassword
   */
  public TwitterConnectStream() {
    try {
      this.SetupStream( TwitterUsername, TwitterPassword);
    } 
    catch (TwitterException is) {
      // screen name / password combination is not in twitter4j.properties

        println("something went wrong!");
      System.exit(-1);
    }
  }

  public void SetupStream(String Username, String Password) throws TwitterException {
    this.PrintSampleStream(Username, Password);
    this.startConsuming();
    println("start consuming");
  }

  TwitterStream twitterStream;

  public void PrintSampleStream(String Username, String Password) {
    try {
      twitterStream = new TwitterStreamFactory(this).getInstance();
    } 
    catch (IllegalStateException is) {
      // screen name / password combination is not in twitter4j.properties
      if (Password == "") {
        println("Please set a TWITTER username and password in config.pde");
        System.exit(-1);
      }
      twitterStream = new TwitterStreamFactory().getInstance(Username, Password);
    }
  }
  private void startConsuming() throws TwitterException {
    // sample() method internally creates a thread which manipulates TwitterStream and calls these adequate listener methods continuously.
    twitterStream.setStatusListener(this);
    // int[] followUserIDs = { 62130733, 69362660 };
    // FilterQuery userStatus = new FilterQuery( TwitterFollowIDs );
    // String[] trackWords = { "playaround", "honf", "love", "facebook", "hate" };
    FilterQuery userStatus = new FilterQuery( 0, TwitterFollowIDs, TwitterTrackWords );
    twitterStream.filter( userStatus );
  }

  public void onStatus(Status status) {
    println( status.getUser().getName() + " : " + status.getText() );
    TwitterToOsc( status.getUser().getName(), status.getText()) ;
  }

  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
  }

  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
  }

  public void onException(Exception ex) {
    ex.printStackTrace();
  }
}

void TwitterToOsc(String TwitterSender, String TwitterMessage) {
  if ( OscSanitize ) {
    TwitterSender =  TwitterSender.replaceAll("[^(!()*+,-.0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{|}\\x20)]","*");
    TwitterMessage = TwitterMessage.replaceAll("[^(!()*+,-.0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{|}\\x20)]","*");
  }
  OscMessage SendOscMessage = new OscMessage(OscSendAddress);
  SendOscMessage.add(TwitterSender);
  String[] OscMessageArguments = split(TwitterMessage, ' ');
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
  }
  oscP5.send(SendOscMessage, OscDestination);
  ActivityLogAddLine("OSC SEND " + OscSendAddress + " " + TwitterSender + " " + TwitterMessage);
}



