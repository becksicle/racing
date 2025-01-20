class World {
  PVector joyDir;
  ArrayList<GameObject> gameObjects = new ArrayList<GameObject>();
  Track track;

  ArrayList<GameObject> toRemove = new ArrayList<GameObject>();
  ArrayList<GameObject> toAdd = new ArrayList<GameObject>();

  World() {
    this.track = new Track();
  }

  void add(GameObject gobj) {
    gameObjects.add(gobj);
  }

  HumanCar getFirstHumanCar() {
    for (GameObject obj : gameObjects) {
      if (obj instanceof HumanCar) {
        return (HumanCar)obj;
      }
    }
    return null;
  }

  void update() {
    toRemove.clear();
    toAdd.clear();

    for (GameObject obj : gameObjects) {
      obj.update(this);
      if (obj.isCollidingWithTrack(track)) {
        obj.handleTrackCollision(track);
      }
      for (GameObject other : gameObjects) {
        if (obj == other) {
          continue;
        }
        if (obj.isCollidingWithGameObject(other)) {
          // need to store these since handling the collision will change them
          float ox = obj.x, oy = obj.y, ovx = obj.vx, ovy = obj.vy;
          obj.handleGameObjectCollision(other.x, other.y, other.vx, other.vy, other, toAdd);
          other.handleGameObjectCollision(ox, oy, ovx, ovy, obj, toAdd);
        }
      }
      if (obj.isDead()) {
        toRemove.add(obj);
      }
    }

    for (GameObject obj : toRemove) {
      println("removing "+obj);
      gameObjects.remove(obj);
    }
    for (GameObject obj : toAdd) {
      gameObjects.add(obj);
    }
  }

  void draw(Camera camera) {
    track.draw(camera);
    for (GameObject obj : gameObjects) {
      obj.draw(camera);
    }
  }
}
