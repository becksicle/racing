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
    this.radius = 8;
  }

  int timeAlive () {
    return millis() - birthTime;
  }
}

class Projectile extends Item {
  boolean released = false;
  int currentSegment;

  Projectile(Car owner) {
    super(owner);
    hasBody = true;
  }

  void handleGameObjectCollision(float ox, float oy, float ovx, float ovy, GameObject other, ArrayList<GameObject> toAdd) {
    if(released && !hasExpired && (other instanceof Car)) {
      println("collided with gobj - dead now");
      hasExpired = true;
    }
  }

  void handleTrackCollision(Track track) {
    println("collided with track");
    vx = -vx;
    vy = -vy;
    x += vx*5;
    y += vy*5;
  }

  void update(World world) {
    
    if (keyPressed && key == ' ') {
      released = true;
      birthTime = millis();
      PVector dir = new PVector(owner.vx, owner.vy).normalize();
      vx = dir.x*15;
      vy = dir.y*15;
    }

    if (released) {
      x += vx;
      y += vy;
      println("released update: "+x+","+y+","+vx+","+vy+" time alive: "+timeAlive()+ " "+hasExpired);
      if (timeAlive() > 10000) {
        hasExpired = true;
        println("expired!");
      }
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
    if(hasExpired) println("dead "+this+" "+millis());
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
      toAdd.add(makeItem((Car)other));
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
