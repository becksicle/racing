class Item {
  static final int PROJECTILE = 0;
  static final int SPEEDUP = 1;

  boolean hasExpired = false;
  boolean hasBody = false;
  float x, y, vx=0, vy=0;

  int birthTime = millis();
  Car owner;
  
  Item(Car owner) {
    this.owner = owner;
  }

  int timeAlive () {
    return millis() - birthTime;
  }

  void update() {
  }
  
  void draw(Camera cam) {
  }
}

class Projectile extends Item {
  boolean released = false;
  int radius = 8;
  
  Projectile(Car owner) {
    super(owner);
    hasBody = true;
  }

  void update() {
    if (key == ' ') {
      released = true;
      birthTime = millis();
      PVector dir = new PVector(owner.vx, owner.vy).normalize();
      vx = dir.x*10;
      vy = dir.y*10;
    }

    if (released) {
      x += vx;
      y += vy;
      if (timeAlive() > 10000) {
        hasExpired = true;
      }
    } else {
      PVector dir = new PVector(owner.vx, owner.vy).normalize();
      x = owner.x + dir.x*owner.radius*0.7;
      y = owner.y + dir.y*owner.radius*0.7;
    }
  }

  void draw(Camera cam) {
    fill(0, 255, 0);
    circle(cam.sx(x), cam.sy(y), cam.sl(radius));
  }
}

class Speedup extends Item {
  Speedup(Car owner) {
    super(owner);
  }
}


class SpawnPoint {
  float x, y, radius = 15;
  color c;

  boolean hasItem = true;
  int lastSpawnTime = millis();
  int itemType;

  int COOL_DOWN_TIME = 5000;

  SpawnPoint(float x, float y, color c, int itemType) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.itemType = itemType;
  }

  void update() {
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
    } else if (itemType == Item.SPEEDUP) {
      return new Speedup(owner);
    }

    return null;
  }
}
