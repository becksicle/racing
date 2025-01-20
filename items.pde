abstract class Item extends GameObject {
  static final int PROJECTILE = 0;
  static final int SPEEDUP = 1;

  boolean hasExpired = false;
  boolean hasBody = false;

  int birthTime = millis();
  Car owner;

  Item(Car owner) {
    c = color(0, 255, 0);
    this.owner = owner;
    owner.item = this;
    this.radius = 8;
  }

  int timeAlive () {
    return millis() - birthTime;
  }
}

class Projectile extends Item {
  boolean released = false;

  Projectile(Car owner) {
    super(owner);
    hasBody = true;
  }

  void handleGameObjectCollision(float ox, float oy, float ovx, float ovy, GameObject other, ArrayList<GameObject> toAdd) {
    if (released && !hasExpired && (other instanceof Car)) {
      hasExpired = true;
    }
  }

  void handleTrackCollision(Track track) {
    vx = -vx;
    vy = -vy;
    x += vx*5;
    y += vy*5;
  }

  void updateReleased(World world) {
    Track track = world.track;
    int ts = track.coords[0].size();
    
    PVector targetPoint = track.getCenterPoint((currentSegment + 1) % ts);
    PVector dirVec = new PVector(targetPoint.x - x, targetPoint.y - y).normalize();
    
    for(GameObject gobj : world.gameObjects) {
      if(gobj.currentSegment != currentSegment 
          && gobj.currentSegment != ((currentSegment + 1) % ts)) continue;
      if(!(gobj instanceof Car)) continue;
        Car car = (Car)gobj;
        PVector v1 = new PVector(targetPoint.x - x, targetPoint.y - y);
        PVector v2 = new PVector(car.x - x, car.y - y);
        if(abs(PVector.angleBetween(v, v2)) < PI/2.0) {
          dirVec = v2.normalize();
        }
    }
     
    // Blend the new direction with the current velocity direction for smoother steering
    vx = dirVec.x * 15;
    vy = dirVec.y * 15;

    x += vx;
    y += vy;
    
    //println("released update: "+x+","+y+","+vx+","+vy+" time alive: "+timeAlive()+ " "+hasExpired+" segment: "+currentSegment);
    
    if (timeAlive() > 10000) {
      hasExpired = true;
    }
  }

  void update(World world) {
    if (!released && keyPressed && key == ' ') {
      released = true;
      birthTime = millis();
      PVector dir = new PVector(owner.vx, owner.vy).normalize();
      vx = dir.x*15;
      vy = dir.y*15;
      owner.item = null;
      owner = null;
    }

    if (released) {
      updateReleased(world);
    } else {
      PVector dir = new PVector(owner.vx, owner.vy).normalize();
      x = owner.x + dir.x*owner.radius*0.7;
      y = owner.y + dir.y*owner.radius*0.7;
    }

    currentSegment = world.track.locateSegment(this);
  }

  void draw(Camera cam) {
    fill(c);
    circle(cam.sx(x), cam.sy(y), cam.sl(radius));
  }

  boolean isDead() {
    return hasExpired;
  }
}

class SpawnPoint extends GameObject {

  boolean hasItem = true;
  int lastSpawnTime = millis();
  int itemType;

  int COOL_DOWN_TIME = 5000;

  SpawnPoint(float x, float y, color c, int itemType) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.radius = 15;
    this.itemType = itemType;
  }

  void handleTrackCollision(Track track) {
    return;
  }

  void handleGameObjectCollision(float ox, float oy, float ovx, float ovy, GameObject other, ArrayList<GameObject> toAdd) {
    if (hasItem && other instanceof Car) {
      Car car = (Car)other;
      if (car.item != null) return;
      toAdd.add(makeItem(car));
    }
  }

  void update(World world) {
    if (!hasItem && (millis() - lastSpawnTime) > COOL_DOWN_TIME) {
      hasItem = true;
      lastSpawnTime = millis();
    }
  }

  void draw(Camera cam) {
    if (hasItem) {
      fill(c);
    } else {
      fill(100, 100, 100);
    }
    stroke(255, 255, 255);
    circle(cam.sx(x), cam.sy(y), cam.sl(radius));
  }

  Item makeItem(Car owner) {
    hasItem = false;
    if (itemType == Item.PROJECTILE) {
      return new Projectile(owner);
    }
    return null;
  }
}
