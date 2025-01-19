class DriverAttrs {
  float maxSpeed = 10;
  float handling = 0.2;
  float jitter = 1.0;

  DriverAttrs(float maxSpeed, float handling, float jitter) {
    this.maxSpeed = maxSpeed;
    this.handling = handling;
    this.jitter = jitter;
  }
}


class Car extends GameObject {
  float tvx, tvy;
  int lastPassedSegment = 0;
  int lap = 1;
  int lastMillis = millis();
  int elapsedTime;
  int cooldown;
  ArrayList<Integer> lapTimes = new ArrayList<Integer>();
  DriverAttrs attrs = null;


  Car(float x, float y, color c, DriverAttrs attrs) {
    this.radius = 25;
    this.x = x;
    this.y = y;
    this.c = c;

    vx = 0;
    vy = 0;

    lastMillis = millis();
    lapTimes.add(0);
    this.attrs = attrs;
  }

  //boolean overlapsCircle(float x, float y, float radius) {
  //  double dx = x - this.x;
  //  double dy = y - this.y;
  //  double distance = Math.sqrt(dx * dx + dy * dy);
  //  return (distance <= radius);
  //}

  void update(World world) {
    updateElapsedTime();
    updateCooldown();
    updateElapsedLapTime();
    currentSegment = world.track.locateSegment(this);
    if (world.track.isNextSegment(lastPassedSegment, currentSegment)) {
      passSegment();
    }
  }

  void handleGameObjectCollision(float ox, float oy, float ovx, float ovy, GameObject other, ArrayList<GameObject> toAdd) {
    if (other instanceof Projectile) {
      Projectile proj = (Projectile)other;
      if(proj.released) {
        cooldown = 3000;
        vx = 0;
        vy = 0;
      }
      return;
    } else if (other instanceof SpawnPoint) {
      return;
    }else {
      float distance = dist(ox, oy, x, y);

      double dx = ox - this.x;
      double dy = oy - this.y;
      
      // Normalized vector of the collision
      double nx = dx / distance;
      double ny = dy / distance;

      // Calculate the relative velocity
      double dvx = ovx - this.vx;
      double dvy = ovy - this.vy;

      // Relative velocity along the normal direction
      double velocityAlongNormal = dvx * nx + dvy * ny;

      // If cars are moving away from each other, no collision response is needed
      if (velocityAlongNormal > 0) return;

      // Assuming elastic collision, calculate the impulse
      double impulse = -2 * velocityAlongNormal;

      // Apply impulse to the cars velocities
      this.vx -= impulse * nx;
      this.vy -= impulse * ny;

      //// Optional: Slightly adjust positions to prevent overlap
      //double overlap = (this.radius + other.radius - distance) / 2;
      //this.x -= overlap * nx;
      //this.y -= overlap * ny;
    }
  }

  void handleTrackCollision(Track track) {
    x += -vx;
    y += -vy;
    vx = 0;
    vy = 0;
    tvx = 0;
    tvy = 0;
    cooldown = 2000;
  }

  void updateElapsedTime() {
    elapsedTime = millis() - lastMillis;
    lastMillis = millis();
  }
  
  void updateCooldown() {
    cooldown = max(0, cooldown-elapsedTime);
  }
  
  void updateElapsedLapTime() {
    int lapElapsed = lapTimes.get(lap-1);
    lapTimes.set(lap-1, lapElapsed+elapsedTime);
  }

  void passSegment() {
    lastPassedSegment = currentSegment;
    if (lastPassedSegment == 0) {
      lap++;
      lapTimes.add(0);
    }
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

class AICar extends Car {
  AICar(float x, float y, color c, DriverAttrs attrs) {
    super(x, y, c, attrs);
  }

  void update(World world) {
    super.update(world);
    if(cooldown > 0) {
      return;
    }
    
    Track track = world.track;
    PVector targetPoint = track.getCenterPoint((lastPassedSegment + 1) % track.coords[0].size());

    // Calculate direction towards target point
    PVector dirVec = new PVector(targetPoint.x - x, targetPoint.y - y).normalize();
    float error = random(2*attrs.jitter) - attrs.jitter;
    dirVec.x += error;
    dirVec.y += error;
    dirVec = dirVec.normalize();

    // Blend the new direction with the current velocity direction for smoother steering
    vx = (1 - attrs.handling) * vx + attrs.handling * dirVec.x*attrs.maxSpeed;
    vy = (1 - attrs.handling) * vy + attrs.handling * dirVec.y*attrs.maxSpeed;

    // Update position
    x += vx;
    y += vy;
  }
}

class HumanCar extends Car {

  HumanCar(float x, float y, color c) {
    super(x, y, c, null);
  }

  void update(World world) {
    super.update(world);
    if(cooldown > 0) {
      return;
    }
    PVector dir = world.joyDir;
    tvx = dir.x*10;
    tvy = -dir.y*10;

    vx = vx + (tvx - vx)*0.01;
    vy = vy + (tvy - vy)*0.01;

    x += vx;
    y += vy;
  }
}
