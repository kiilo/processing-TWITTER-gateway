PImage backgr;

void setup() {
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

void draw() {
  if (!Authorized) {
    AuthorizeTwitter();
  }
  //PImage b = loadImage("backgr.png");
  background(backgr);
  controlP5.draw();
  delay(5);
}


