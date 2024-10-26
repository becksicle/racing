class Car {
  float x, y, vx, vy, tvx, tvy, radius = 25;
  
  int lastPassedSegment = 0;
  int lap = 1;
  int lastMillis = millis();
  ArrayList<Integer> lapTimes = new ArrayList<Integer>();
  
  Car(float x, float y) {
    this.x = x;
    this.y = y;
    vx = 0;
    vy = 1;
    
    lastMillis = millis();
    lapTimes.add(0);
  }
  
  void updateElapsedLapTime() {
    int elapsedTime = millis() - lastMillis;
    lastMillis = millis();
    
    int lapElapsed = lapTimes.get(lap-1);
    lapTimes.set(lap-1, lapElapsed+elapsedTime);
  }
  
  void passSegment(int segment) {
    lastPassedSegment = segment;
    if(lastPassedSegment == 0) {
      lap++;
      lapTimes.add(0);
     } 
  }
  
  void update(PVector dir) {
    tvx = dir.x*10;
    tvy = -dir.y*10;
    
    vx = vx + (tvx - vx)*0.01;
    vy = vy + (tvy - vy)*0.01;
    
    x += vx;
    y += vy;
  }
  
  void update(Track track) {
  }
  
  void draw(Camera c) {
    
    fill(240, 100, 100);
    stroke(255, 255, 255);
    
    circle(c.sx(x), c.sy(y), c.sl(radius));
    
    stroke(0, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+vx*c.sl(20), c.sy(y)-vy*c.sl(20));
    
    stroke(255, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+tvx*c.sl(20), c.sy(y)-tvy*c.sl(20));
    
  }
  
}
