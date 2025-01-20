abstract class GameObject {
  float x, y, vx, vy, radius;
  color c;
  int currentSegment; // TODO right now all subclasses have to update this
 
  abstract void update(World world); 
  abstract void draw(Camera camera);
  abstract void handleTrackCollision(Track track);
  abstract void handleGameObjectCollision(float ox, float oy, float ovx, float ovy, GameObject other, ArrayList<GameObject> toAdd);
  
  boolean isCollidingWithGameObject(GameObject other) {
    if(dist(other.x, other.y, x, y) < 10 && other.getClass().getName().contains("Projectile")) {
      println(this.getClass().getName()+this+" to "+other.getClass().getName()+other+" "+dist(other.x, other.y, x, y));
      println("radius: "+min(other.radius, radius));
    }
    return dist(other.x, other.y, x, y) <= min(other.radius, radius);
  }
  
  boolean isCollidingWithTrack(Track track) {
    return track.isGameObjectCollidingWithSegment(currentSegment, this);
  }
  
  boolean isDead() {
    return false;
  }

}
