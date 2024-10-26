class Car {
  float x, y, vx, vy, tvx, tvy, radius = 25;
  
  Car(float x, float y) {
    this.x = x;
    this.y = y;
    vx = 0;
    vy = 1;
  }
  
  void update(PVector dir) {
    tvx = dir.x*10;
    tvy = -dir.y*10;
    
    vx = vx + (tvx - vx)*0.01;
    vy = vy + (tvy - vy)*0.01;
    
    x += vx;
    y += vy;
  }
  
  void draw(Camera c) {
    
    fill(240, 100, 100);
    stroke(255, 255, 255);
    
    //float heading = new PVector(vx, vy).heading();
    //text(heading, 20, 300);
    circle(c.sx(x), c.sy(y), c.sl(radius));
    
    stroke(0, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+vx*c.sl(20), c.sy(y)-vy*c.sl(20));
    
    stroke(255, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+tvx*c.sl(20), c.sy(y)-tvy*c.sl(20));
    
  }
  
}
