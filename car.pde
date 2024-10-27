class Car {
  float x, y, vx, vy, tvx, tvy, radius = 25;
  color c;

  int lastPassedSegment = 0;
  int lap = 1;
  int lastMillis = millis();
  ArrayList<Integer> lapTimes = new ArrayList<Integer>();

  Car(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.c = c;
    
    vx = 0;
    vy = 1;

    lastMillis = millis();
    lapTimes.add(0);
  }

  void doCollision(Car other) {
    // Calculate the distance between the centers
    double dx = other.x - this.x;
    double dy = other.y - this.y;

    double distance = Math.sqrt(dx * dx + dy * dy);

    // no collision
    if (distance > radius) return;

    // Normalized vector of the collision
    double nx = dx / distance;
    double ny = dy / distance;

    // Calculate the relative velocity
    double dvx = other.vx - this.vx;
    double dvy = other.vy - this.vy;

    // Relative velocity along the normal direction
    double velocityAlongNormal = dvx * nx + dvy * ny;

    // If cars are moving away from each other, no collision response is needed
    if (velocityAlongNormal > 0) return;

    // Assuming elastic collision, calculate the impulse
    double impulse = -2 * velocityAlongNormal;

    // Apply impulse to the cars’ velocities
    this.vx -= impulse * nx;
    this.vy -= impulse * ny;
    other.vx += impulse * nx;
    other.vy += impulse * ny;

    // Optional: Slightly adjust positions to prevent overlap
    double overlap = (this.radius + other.radius - distance) / 2;
    this.x -= overlap * nx;
    this.y -= overlap * ny;
    other.x += overlap * nx;
    other.y += overlap * ny;
  }

  void updateElapsedLapTime() {
    int elapsedTime = millis() - lastMillis;
    lastMillis = millis();

    int lapElapsed = lapTimes.get(lap-1);
    lapTimes.set(lap-1, lapElapsed+elapsedTime);
  }

  void passSegment(int segment) {
    lastPassedSegment = segment;
    if (lastPassedSegment == 0) {
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
    PVector targetPoint = track.getCenterPoint((lastPassedSegment + 1) % track.coords[0].size());

    // Calculate direction towards target point
    PVector dirVec = new PVector(targetPoint.x - x, targetPoint.y - y).normalize();

    // Blend the new direction with the current velocity direction for smoother steering
    float blendFactor = 0.2;  // Adjust blend factor for smoothness
    vx = (1 - blendFactor) * vx + blendFactor * dirVec.x*5;
    vy = (1 - blendFactor) * vy + blendFactor * dirVec.y*5;

    // Update position
    x += vx;
    y += vy;
  }

  void draw(Camera c) {

    fill(this.c);
    stroke(255, 255, 255);

    circle(c.sx(x), c.sy(y), c.sl(radius));

    stroke(0, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+vx*c.sl(20), c.sy(y)-vy*c.sl(20));

    stroke(255, 255, 0);
    line(c.sx(x), c.sy(y), c.sx(x)+tvx*c.sl(20), c.sy(y)-tvy*c.sl(20));
  }
}
