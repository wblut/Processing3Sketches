//Find all triangles between two isolevel contours for a grid of values
//https://www.goodreads.com/book/show/16195572-isosurfaces

List<Triangle> isotriangles;//triangles between two isolevel contours
int resx, resy;//resolution of grid
float cx, cy;//center of grid
float dx, dy;//size of grid cell
float zFactor;//(grid values) x zFactor = height of triangle vertices
float[][] values;// grid values

void setup() {
  size(800, 800, P3D);
  smooth(16);
  resx=100;
  resy=100;  
  values=new float[resx+1][resy+1];
  
  for(int i=0;i<=resx;i++){
    for(int j=0;j<=resy;j++){
      values[i][j]= (noise(0.025*i, 0.025*j)-0.1)/0.8;
    }
  }
  
  cx=0;
  cy=0;
  dx=5;
  dy=5;
  zFactor=200.0;
  
  isotriangles=new ArrayList<Triangle>();
  //get triangles between isolevel low and isolevel high, and give the color col: getTriangles(low, high, col) 
  isotriangles.addAll(getTriangles(0.1, 0.15, color(255,0,0)));
  isotriangles.addAll(getTriangles(0.2, 0.25, color(255,128,0)));
  isotriangles.addAll(getTriangles(0.3, 0.35, color(255,255,0)));
  isotriangles.addAll(getTriangles(0.4, 0.45, color(128,255,0)));
  isotriangles.addAll(getTriangles(0.5, 0.55, color(0,255,0)));
  isotriangles.addAll(getTriangles(0.6, 0.65, color(0,255,128)));
  isotriangles.addAll(getTriangles(0.7, 0.75, color(0,128,255)));
  isotriangles.addAll(getTriangles(0.8, 0.85, color(0,0,255)));
  isotriangles.addAll(getTriangles(0.9, 0.95, color(128,0,255)));
}

//This function returns the values of (resX+1)x(resY+1) data points
float getValue(int i, int j) {
  return values[i][j];
}

void draw() {
  background(255);
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  for (Triangle triangle : isotriangles) {
    triangle.draw();
  }
}

class Point {
  float x, y, z;
  Point(float x, float y, float z) {
    this.x=x;
    this.y=y;
    this.z=z;
  }
}

class Triangle {
  Point p1, p2, p3;
  color col;
  Triangle(Point p1, Point p2, Point p3, color col) {
    this.p1=new Point(p1.x, p1.y, p1.z);
    this.p2=new Point(p2.x, p2.y, p2.z);
    this.p3=new Point(p3.x, p3.y, p3.z);
    this.col=col;
  }

  void draw() {
    fill(col);
    beginShape();
    vertex(p1.x, p1.y, p1.z);  
    vertex(p2.x, p2.y, p2.z); 
    vertex(p3.x, p3.y, p3.z);
    endShape(CLOSE);
  }
}
