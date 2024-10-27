Car car = new Car(0, 0, color(255, 100, 100));
Car npc = new Car(10, 10, color(100, 200, 150));

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
  
  text("FPS: "+frameRate, width-300, 40);
  for(int i=0; i < car.lap; i++) {
    text("Lap "+(i+1)+": "+formatTime(car.lapTimes.get(i)), width-300, 70+(i+1)*30);
  }

  car.update(joy.dir);
  npc.update(track);

  track.update(car);
  track.update(npc);
  
  car.doCollision(npc);

  car.draw(camera);
  npc.draw(camera);
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
