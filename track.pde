class Track {
  ArrayList<PVector>[] coords = new ArrayList[] { new ArrayList<PVector>(), new ArrayList<PVector>()};

  PVector getOppositePoint(int pointIndex) {
    return coords[1].get(pointIndex);
  }

  PVector getCenterPoint(int index) {
    PVector innerPoint = coords[0].get(index);
    PVector outerPoint = coords[1].get(index);
    float centerX = (innerPoint.x + outerPoint.x) / 2;
    float centerY = (innerPoint.y + outerPoint.y) / 2;
    return new PVector(centerX, centerY);
  }

  void draw(Camera c) {
    PVector p1, p2;
    for (int j=0; j < coords.length; j++) {
      ArrayList<PVector> tcs = coords[j];
      for (int i=0; i < tcs.size(); i++) {
        p1 = tcs.get(i);
        p2 = tcs.get((i+1)%tcs.size());
        stroke(255, 255, 0);
        line(c.sx(p1.x), c.sy(p1.y), c.sx(p2.x), c.sy(p2.y));
        //if (j == 0) {
        //  PVector p3 = getOppositePoint(i);
        //  line(c.sx(p1.x), c.sy(p1.y), c.sx(p3.x), c.sy(p3.y));
        //}
      }
    }
  }

  void add(float x, float y, int ti) {
    coords[ti].add(new PVector(x, y));
  }

  void clear() {
    for (ArrayList c : coords) {
      c.clear();
    }
  }

  void printAll() {
    String[] strings = new String[coords.length];
    for (int ti=0; ti < coords.length; ti++) {
      strings[ti] = "";
      for (int ci = 0; ci < coords[ti].size(); ci++) {
        strings[ti] += coords[ti].get(ci).x + " " + coords[ti].get(ci).y+" ";
      }
    }
    saveStrings("track.txt", strings);
  }

  int locateSegment(GameObject gobj) {
    ArrayList<PVector> outer = coords[0];
    ArrayList<PVector> inner = coords[1];

    for (int i=0; i < outer.size(); i++) {
      PVector p1 = outer.get(i);
      PVector p2 = outer.get((i+1)%outer.size());
      PVector p4 = inner.get(i);
      PVector p3 = inner.get((i+1)%inner.size());

      if (isPointInQuadrilateral(
        gobj.x, gobj.y,
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y
        )) return i;
    }
    //println("problem! "+gobj.x+", "+gobj.y);
    //int i = gobj.currentSegment;
    //PVector p1 = outer.get(i);
    //PVector p2 = outer.get((i+1)%outer.size());
    //PVector p4 = inner.get(i);
    //PVector p3 = inner.get((i+1)%inner.size());
    //println(isPointInQuadrilateral(
    //    gobj.x, gobj.y,
    //    p1.x, p1.y,
    //    p2.x, p2.y,
    //    p3.x, p3.y,
    //    p4.x, p4.y
    //    ));
    
    return gobj.currentSegment;
  }
  
  boolean isNextSegment(int cur, int next) {
    return ((cur+1) % coords[0].size()) == next;
  }

  boolean isGameObjectCollidingWithSegment(int segment, GameObject gobj) {
    // outer/inner track loops
    for(ArrayList<PVector> pts : coords) {
      PVector p1 = pts.get(segment);
      PVector p2 = pts.get((segment+1)%pts.size());
      PVector intersect = segmentIntersection(
        gobj.x, gobj.y,
        gobj.x + gobj.vx, gobj.y + gobj.vy,
        p1.x, p1.y,
        p2.x, p2.y
        );
      
      if(intersect != null) return true;
    }
    return false;
  }

  void initialize(String[] strings) {
    for (int i=0; i < 2; i++) {
      String[] parts = strings[i].split(" ");
      for (int j=0; j < parts.length; j += 2) {
        coords[i].add(new PVector(Float.parseFloat(parts[j]), Float.parseFloat(parts[j+1])));
      }
    }

    int targetSize = min(coords[0].size(), coords[1].size());
    for (int i=0; i < coords.length; i++) {
      while (coords[i].size() > targetSize) {
        coords[i].remove(coords[i].size()-1);
      }
    }
  }
}
