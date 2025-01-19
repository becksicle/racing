// Helper method to calculate the area of a triangle using the Shoelace formula
double triangleArea(double x1, double y1, double x2, double y2, double x3, double y3) {
  return Math.abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2.0);
}

// Method to check if a point (x, y) is inside the quadrilateral
boolean isPointInQuadrilateral(double x, double y,
  double x1, double y1,
  double x2, double y2,
  double x3, double y3,
  double x4, double y4) {
  // Calculate the area of the quadrilateral
  double quadArea = triangleArea(x1, y1, x2, y2, x3, y3) + triangleArea(x1, y1, x3, y3, x4, y4);

  // Calculate the sum of the areas of triangles formed with the point (x, y)
  double area1 = triangleArea(x, y, x1, y1, x2, y2);
  double area2 = triangleArea(x, y, x2, y2, x3, y3);
  double area3 = triangleArea(x, y, x3, y3, x4, y4);
  double area4 = triangleArea(x, y, x4, y4, x1, y1);

  // Check if the sum of the areas of triangles equals the area of the quadrilateral
  return Math.abs((area1 + area2 + area3 + area4) - quadArea) < 1e-5; // Allow for floating-point precision errors
}

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
