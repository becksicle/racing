class Track {
  ArrayList<PVector>[] coords = new ArrayList[] { new ArrayList<PVector>(), new ArrayList<PVector>()};

  PVector segmentIntersection(
    float x1, float y1,
    float x2, float y2,
    float x3, float y3,
    float x4, float y4
    ) {
    float a = (x4 - x3) * (y3 - y1) - (y4 - y3)*(x3 - x1);
    float b = (x4 - x3)*(y2 - y1) - (y4 - y3)*(x2 - x1);
    float c = (x2 - x1)*(y3 - y1) - (y2 - y1)*(x3 - x1);

    if (b == 0) return null; // segments are parallel
    if (a == 0 && b == 0) return new PVector(x1, y1); // collinear

    float alpha =  a / b;
    float beta = c / b;

    if (alpha < 0 || alpha > 1 || beta < 0 || beta > 1) return null;

    return new PVector(x1 + alpha * (x2-x1), y1 + alpha * (y2 - y1));
  }

  PVector getOppositePoint(int pointIndex) {
    return coords[1].get(pointIndex);
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
        if(j == 0) {
          PVector p3 = getOppositePoint(i);
          //if (lastPassedSegment == i) {
          //  stroke(255, 0, 0);
          //}
          line(c.sx(p1.x), c.sy(p1.y), c.sx(p3.x), c.sy(p3.y));
          
        }
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
    //println("-----------------------------------------");
    String[] strings = new String[coords.length];
    for (int ti=0; ti < coords.length; ti++) {
      strings[ti] = "";
      for (int ci = 0; ci < coords[ti].size(); ci++) {
        strings[ti] += coords[ti].get(ci).x + " " + coords[ti].get(ci).y+" ";
    //    println("coords["+ti+"].add(new PVector("+coords[ti].get(ci).x+", "+coords[ti].get(ci).y+"));");
      }
    }
    saveStrings("track.txt", strings);
    //println("-----------------------------------------");
  }

  PVector update(Car car) {
    car.updateElapsedLapTime();
               
    for (int j=0; j < coords.length; j++) {
      ArrayList<PVector> tcs = coords[j];
      for (int i=0; i < tcs.size(); i++) {
        PVector p1 = tcs.get(i);
        PVector p2 = tcs.get((i+1)%tcs.size());
        
        // check wall collision
        PVector intersect = segmentIntersection(
          car.x, car.y,
          car.x + car.vx, car.y + car.vy,
          p1.x, p1.y,
          p2.x, p2.y
          );
       
       // check if we've passed a segment and/or made a full lap
        if(j == 0 && i == (car.lastPassedSegment + 1) % tcs.size()) {
          PVector p3 = getOppositePoint(i);
          PVector passedIntersect = segmentIntersection(
            car.x, car.y,
            car.x + car.vx, car.y + car.vy,
            p1.x, p1.y,
            p3.x, p3.y
            );
            
           if(passedIntersect != null) {
             car.passSegment(i);
          }
        }
          
        if (intersect != null) {
          return intersect;
        }
      }
    }
    return null;
  }

  void initialize(String[] strings) {
    for(int i=0; i < 2; i++) {
      String[] parts = strings[i].split(" ");
      for(int j=0; j < parts.length; j += 2) {
        coords[i].add(new PVector(Float.parseFloat(parts[j]), Float.parseFloat(parts[j+1])));
      }
    }
    
    int targetSize = min(coords[0].size(), coords[1].size());
    for(int i=0; i < coords.length; i++) {
      while(coords[i].size() > targetSize) {
        coords[i].remove(coords[i].size()-1);
      }
    }
  }
}
