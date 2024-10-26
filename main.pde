Car car = new Car(0, 0);
Camera camera = new Camera();
Track track = new Track();

Joystick joy = new Joystick();
PVector collidePoint = null;
PVector testCollidePoint = null;
boolean autoCam = true;

String[] displayStrs = new String[] {
  "a,d,w,s to control camera",
  "z,x to zoom",
  "1,2 to add track points",
  "` to clear",
  "p to save track",
  "0 to cam follow car",
};


String formatTime(int ms) {
  int minutes = ms / (1000 * 60);
  ms -= minutes * 1000 * 60;
  int seconds = ms / 1000;
  ms -= seconds * 1000;
  if(minutes > 0) {
    String toReturn = minutes+":";
    if(seconds < 10) toReturn += "0";
    toReturn += seconds+"."+ms;
    return toReturn;
  } else {
    return seconds+"."+ms;
  }
  
}

void setup() {
  rectMode(CENTER);
  size(1100, 600);
  String[] strings = loadStrings("track.txt");
  track.initialize(strings);
}

void draw() {
  background(0);

  fill(255, 255, 255);
  textSize(20);
  handleKeys();
  
  for(int i=0; i < displayStrs.length; i++) {
    text(displayStrs[i], 10, i*20 + 40);
  }
  textSize(80);
  text("Lap "+track.lap, width-300, 80);
  textSize(30);
  for(int i=0; i < track.lap; i++) {
    text("Lap "+(i+1)+": "+formatTime(track.lapTimes.get(i)), width-300, 100+(i+1)*30, width, 100+(i+2)*30);
  }

  car.update(joy.dir);

  testCollidePoint = track.update(car);
  if (testCollidePoint != null) {
    collidePoint = testCollidePoint;
    //PVector d = new PVector(-car.vx, -car.vy);
    //d.normalize().mult(car.radius);
    //car.x += d.x;
    //car.y += d.y;
    car.vx = -car.vx;
    car.vy = -car.vy;
    
  }

  if (collidePoint != null) {
    stroke(255, 0, 255);
    circle(camera.sx(collidePoint.x), camera.sy(collidePoint.y), 10);
  }


  car.draw(camera);
  track.draw(camera);

  joy.update();
  joy.draw();

  if(autoCam) {
    float dcx = car.x - camera.px;
    float dcy = car.y - camera.py;
    camera.px += 0.05 * dcx;
    camera.py += 0.05 * dcy;
  }
}

void handleKeys() {
  if (!keyPressed) return;

  if (key == 'w') {
    camera.py += 10;
    autoCam = false;
  } else if (key == 's') {
    camera.py -= 10;
    autoCam = false;
  } else if (key == 'a') {
    camera.px -= 10;
    autoCam = false;
  } else if (key == 'd') {
    camera.px += 10;
    autoCam = false;
  } else if (key == 'z') {
    camera.zoom += 0.01;
  } else if (key == 'x') {
    camera.zoom -= 0.01;
  }
}


void keyPressed() {
  if (key == '1') {
    track.add(camera.wx(mouseX), camera.wy(mouseY), 0);
  } else if (key == '2') {
    track.add(camera.wx(mouseX), camera.wy(mouseY), 1);
  } else if (key =='p') {
    track.printAll();
  } else if (key == '0') {
    autoCam = true;
  } else if (key == '`') {
    track.clear();
  }
}
