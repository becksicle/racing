World world = new World();
Camera camera = new Camera();

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
  if (minutes > 0) {
    String toReturn = minutes+":";
    if (seconds < 10) toReturn += "0";
    toReturn += seconds+"."+ms;
    return toReturn;
  } else {
    return seconds+"."+ms;
  }
}

void setup() {
  world.add(new HumanCar(0, 0, color(255, 100, 100)));
  world.add(new AICar(10, 10, color(100, 200, 150), new DriverAttrs(8.0, 0.01, 0.6)));
  world.add(new AICar(20, 20, color(150, 200, 100), new DriverAttrs(6.0, 0.05, 0.2)));
  world.add(new AICar(30, 30, color(200, 150, 150), new DriverAttrs(5.0, 0.1, 0.1)));
  world.add(new AICar(40, 40, color(150, 50, 200), new DriverAttrs(10.0, 0.1, 0.6)));
  world.add(new SpawnPoint(25, 25, color(255, 255, 255), Item.PROJECTILE));
  
  rectMode(CENTER);
  size(1100, 600);
  String[] strings = loadStrings("track.txt");
  world.track.initialize(strings);
}

void draw() {
  background(0);

  fill(255, 255, 255);
  textSize(20);
  handleKeys();

  for (int i=0; i < displayStrs.length; i++) {
    text(displayStrs[i], 10, i*20 + 40);
  }

  //text("FPS: "+frameRate, width-300, 40);
  Car car = (Car)world.getFirstHumanCar();
  for (int i=0; i < car.lap; i++) {
    stroke(car.c);
    text("Lap "+(i+1)+": "+formatTime(car.lapTimes.get(i)), width-300, 40+(i+1)*30);
  }

  world.joyDir = joy.dir;
  world.update();
  world.draw(camera);

  joy.update();
  joy.draw();

  if (autoCam) {
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
    world.track.add(camera.wx(mouseX), camera.wy(mouseY), 0);
  } else if (key == '2') {
    world.track.add(camera.wx(mouseX), camera.wy(mouseY), 1);
  } else if (key =='p') {
    world.track.printAll();
  } else if (key == '0') {
    autoCam = true;
  } else if (key == '`') {
    world.track.clear();
  }
}
