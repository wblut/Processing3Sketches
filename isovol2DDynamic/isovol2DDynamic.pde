//Find all triangles between two isolevel contours for a grid of values
//https://www.goodreads.com/book/show/16195572-isosurfaces

List<Triangle> isotriangles,isotriangles2;//triangles between two isolevel contours
int resx, resy;//resolution of grid
float cx, cy;//center of grid
float dx, dy;//size of grid cell
float zFactor;//(grid values) x zFactor = height of triangle vertices


void setup() {
  size(800, 800, P3D);
  smooth(16);
  resx=100;
  resy=100;  

  cx=0;
  cy=0;
  dx=5;
  dy=5;
  zFactor=200.0;
}

//This function returns the values of (resX+1)x(resY+1) data points
float getValue(int i, int j) {
  return 1.0-2.0*(noise(0.025*i, 0.025*j,0.0025*frameCount)-0.1)/0.8 ;
}

void draw() {
  background(255);
  
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  isotriangles2=getTriangles(-1.0, 1.0, color(255));
  noFill();
  stroke(0);
  for (Triangle triangle : isotriangles2) {
    triangle.draw();
  }
  noStroke();
  isotriangles=getTriangles((frameCount%100)*0.02-1.0, (frameCount%100)*0.02-.9, color(255,0,0));
  for (Triangle triangle : isotriangles) {
    fill(triangle.col);
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
    
    beginShape();
    vertex(p1.x, p1.y, p1.z);  
    vertex(p2.x, p2.y, p2.z); 
    vertex(p3.x, p3.y, p3.z);
    endShape(CLOSE);
  }
}
