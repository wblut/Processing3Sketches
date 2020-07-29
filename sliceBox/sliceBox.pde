ArrayList<SliceBox> sliceBoxes;
int GAP;
float CHANCE;

void setup() {
  size(1000, 1000, P3D);
  smooth(16);
  sliceBoxes=new ArrayList<SliceBox> ();
  SliceBox sliceBox=new SliceBox();
  sliceBox.createBoxWithCenterAndSize(0, 0, 0, 300, 300, 300);
  sliceBoxes.add( sliceBox);
  GAP=20;
  CHANCE=1.0;
}

void draw() {
  background(250);
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  hint(DISABLE_DEPTH_MASK);
  stroke(0);
  fill(0, 25);
  for (SliceBox sliceBox : sliceBoxes) {
    sliceBox.draw();
  }
  hint(ENABLE_DEPTH_MASK);
}

void slice(PVector origin, PVector normal, float gap, float chance) {
  ArrayList<SliceBox> newSliceBoxes=new ArrayList<SliceBox> ();
  PVector N=new PVector(normal.x, normal.y, normal.z);
  N.normalize();
  PVector Nflip=new PVector(-N.x, -N.y, -N.z);
  for (SliceBox sliceBox : sliceBoxes) {
    if (random(1.0)<chance) {
      SliceBox copy=sliceBox.copy();
      sliceBox.slice(origin, N, 0.5*gap);
      if (sliceBox.isValid() && sliceBox.vertices.size()>0) newSliceBoxes.add(sliceBox);
      copy.slice(origin, Nflip, 0.5*gap);
      if (copy.isValid() && copy.vertices.size()>0) newSliceBoxes.add(copy);
    } else {
      newSliceBoxes.add(sliceBox);
    }
  }
  sliceBoxes=newSliceBoxes;
}

void mousePressed() {
  PVector normal=new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
  /*
  int roll=(int)random(3.0);
   switch(roll) {
   case 0:
   normal=new PVector(1, 0, 0);
   break;
   case 1:
   normal=new PVector(0, 1, 0);
   break;
   default:
   normal=new PVector(0, 0, 1);
   }
   */
  PVector origin=new PVector(40*(int)random(-4, 5), 40*(int)random(-4, 5), 40*(int)random(-4, 5));
  slice(origin, normal, GAP, CHANCE);
}
