import controlP5.*;


ControlP5 controlP5;

//int myColorBackground = color(0,0,0);
//int sliderValue = 100;

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
  ActivityLogAddLine("setup ...");

  /* OK this tabbed view willl be done later
   // STATUS tab
   controlP5.addButton("button",10,100,80,80,20);
   RecvPort = controlP5.addTextlabel("RecvPort","recv PORT",16,32);
   RecvPort.setColorValue(0x1f1f1f);
   SendDest = controlP5.addTextlabel("SendDest","send DEST",16,48);
   SendDest.setColorValue(0x1f1f1f);
   controlP5.controller("button").moveTo("status");
   controlP5.controller("RecvPort").moveTo("status");
   controlP5.controller("SendDest").moveTo("status");
   
   //SETTINGS TAB
   SetRecvPort = controlP5.addTextfield("set port",16,32, 64,16);
   SetSendDest = controlP5.addTextfield("set destination:port",16,64,256,16);
   SetRecvPort.setAutoClear(false);
   SetSendDest.setAutoClear(false);
   controlP5.controller("set port").moveTo("settings");
   controlP5.controller("set destination:port").moveTo("settings");
   
   
   controlP5.tab("settings").setColorForeground(0xffff0000);
   controlP5.tab("settings").setColorBackground(0xff330000);
   
   controlP5.trigger();
   
   // in case you want to receive a controlEvent when
   // a  tab is clicked, use activeEvent(true)
   controlP5.tab("settings").activateEvent(true);
   controlP5.tab("settings").setId(0);
   
   controlP5.tab("status").activateEvent(false);
   //controlP5.tab("default").setLabel("status");
   controlP5.tab("status").setId(1);
   */
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
    println("controller : "+theControlEvent.controller().label());
  } 
  else if (theControlEvent.isTab()) {
    println("tab : "+theControlEvent.tab().id()+" / "+theControlEvent.tab().name());

  }
}

void ActivityLogAddLine(String aTextLine) {
  //println(ActivityLogTextarea.text().length());
  while (ActivityLogTextarea.text().length() > 5000) {
    int IndexOfFirstLine = ActivityLogTextarea.text().indexOf("\n");
    if ( ActivityLogTextarea.text().length() > (IndexOfFirstLine + 1) ) {
      //println( IndexOfFirstLine );
      ActivityLogTextarea.setText(ActivityLogTextarea.text().substring(IndexOfFirstLine+1));
    }
  }
  int length =  aTextLine.length();
  String TimeStamp = String.valueOf(day())+"."+String.valueOf(month())+"."+String.valueOf(year())+" "+String.valueOf(hour())+":"+String.valueOf(minute())+":"+String.valueOf(second());
  String aMessage = aTextLine.replaceAll("[^(!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{|}~\\x20)]","*");
  ActivityLogTextarea.setText(ActivityLogTextarea.text()+TimeStamp+" "+aMessage+"\n");
  
}


