class Camera {
  // px, py will be where the camera is focused/center of the screen
  float zoom = 1.0, px, py;
   
  float sx(float wx) {
     return (width/2 + (wx - px)*zoom);
  }
  
  float sy(float wy) {
    return (height/2 - (wy - py)*zoom);
  }
  
  float wx(int sx) {
    return (sx - (width / 2)) / zoom + px;
  }
  
  float wy(int sy) {
    return py - (sy - (height / 2)) / zoom;
  }
  
  float sl(float l) {
    return zoom * l;
  }
}
