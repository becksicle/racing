
class Joystick {
  float px, py;
  float x, y;
  boolean dragging = false;
  PVector dir = new PVector(0, 0);
  float MAX_MAG = 55;

  void update() {
    if (keyPressed) {
      if (dragging) {
        dir.set(mouseX-px, mouseY-py);
        if (dir.mag() > MAX_MAG) {
          dir.normalize(dir);
          PVector.mult(dir, MAX_MAG, dir);
        }
        x = px + dir.x;
        y = py + dir.y;
      } else {
        dragging = true;
        px = mouseX;
        py = mouseY;
        x = px;
        y = py;
        dir.set(0, 0);
      }
    } else {
      dragging = false;
      dir.set(0, 0);
    }
    
    PVector.div(dir, MAX_MAG, dir);
  }

  void draw() {
    if (dragging) {
      fill(255, 255, 255, 80);
      stroke(255, 255, 255);
      circle(px, py, 100);
      line(px, py, x, y);
      circle(x, y, 35);
    }
  }
}
