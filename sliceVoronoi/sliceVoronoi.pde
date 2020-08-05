ArrayList<SliceBox> vorCells;
ArrayList<PVector> vorPoints;
int numPoints;
int GAP;
float CHANCE;

void setup() {
  size(1000, 1000, P3D);
  smooth(16);

  create();
}

//Brute force, unoptimized Voronoi
void create() {
  vorCells=new ArrayList<SliceBox> ();
  vorPoints = new ArrayList<PVector> ();
  int numPoints =100;
  for (int i=0; i<numPoints; i++) {
    vorPoints.add(new PVector(random(-150, 150), random(-150, 150), random(-300, 200)));
  }
  boolean empty;
  GAP=10;
  for (int i=0; i<numPoints; i++) {
    println("Trying to create cell "+(i+1)+".");
    SliceBox sliceBox=new SliceBox();
    sliceBox.createOcathedronWithCenterAndSize(0, 0, 0, 300, 300, 600);
    empty = false;
    for (int j=0; j<numPoints; j++) {
      if (i!=j) {
        PVector origin=PVector.add(vorPoints.get(i), vorPoints.get(j));
        origin.mult(0.5);
        PVector normal=PVector.sub(vorPoints.get(j), vorPoints.get(i));
        normal.normalize();
        sliceBox.slice(origin, normal,(origin.z+300)/30.0);
        if (!sliceBox.isValid() || sliceBox.vertices.size()==0) {
          empty=true;
          break;
        }
      }
    }
    if (!empty) vorCells.add(sliceBox);
  }
}

void draw() {
  background(240);
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  hint(DISABLE_DEPTH_MASK);
  stroke(0);
  fill(0, 25);
  for (SliceBox vorCell : vorCells) {
    vorCell.draw();
  }
  hint(ENABLE_DEPTH_MASK);
}



void mousePressed() {
  create();
}
