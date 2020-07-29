import java.util.Set;
import java.util.HashSet;
SliceTree tree;
int slices;
float phase;

float rotation;
float translation;

Set<Integer> xRolls;
Set<Integer> yRolls;
Set<Integer> zRolls;

void setup() {
  size(1000,1000,P3D);
  smooth(16);
  noCursor();
  rotation=0.4;
  translation=0.4;
  slices=20;
  init();  
}

void init(){
  /*
  SliceBox sliceBox=new SliceBox();
  sliceBox.createBoxWithCenterAndSize(0,0,0,300,300,300);
  tree=new SliceTree(sliceBox);
  */
  ArrayList<SliceBox> sliceBoxes=new ArrayList<SliceBox>();
  SliceBox sliceBox;
  for(int i=0;i<10;i++){
   sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(-185+30*i,0,0,25,300,300);
    sliceBoxes.add(sliceBox);
  }
  tree=new SliceTree(sliceBoxes);
  
  for (int r=0; r<slices; r++) {
    slice(r,5,0.0);
  }
  
}

void slice(int slicecount, float explode, float explodePerLevel) {
  xRolls=new HashSet<Integer>();
  yRolls=new HashSet<Integer>();
  zRolls=new HashSet<Integer>();
  Transformation M;
  float roll=random(1.0);
  if (roll<rotation) {
    M=sliceAndRotate(explode, explodePerLevel);
  } else if (roll<rotation+translation) {
    M=sliceAndTranslate(explode, explodePerLevel);
  } else  {
    M=sliceAndShear(explode, explodePerLevel);
  } 
  M.level=slicecount;
  tree.split(M);
}

Transformation sliceAndRotate(float explode, float explodePerLevel) {
  PVector origin;
  PVector normal; 
  int dirRoll=(int)random(3);
  int roll=-1;
  switch(dirRoll) {
  case 0:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);
    origin=new PVector(-50+100*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 1:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);
    origin=new PVector(0, -50+100*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    break;
  default:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);
    origin=new PVector(0, 0, -50+100*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1);
  }

  float angle=PI/2.0;
  return new Transformation(origin, normal, angle, ROTATION,explode, explodePerLevel);
}

Transformation sliceAndTranslate(float explode, float explodePerLevel) {
  PVector origin;
  PVector normal; 
  PVector direction;

  int roll=-1;
  int planeRoll=(int)random(6);

  switch(planeRoll) {
  case 0:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);
    origin=new PVector(-50+100*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  case 1:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);
    origin=new PVector(0, -50+100*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break; 
  case 2:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);
    origin=new PVector(0, 0, -50+100*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 3:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);
    origin=new PVector(-50+100*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break;
  case 4:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);
    origin=new PVector(0, -50+100*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  default:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);
    origin=new PVector(0, 0, -50+100*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  }

  float displacement =25.0*(int)random(1.0, 5.0);
  return new Transformation(origin, normal, displacement, direction, TRANSLATION,explode, explodePerLevel);
}


Transformation sliceAndShear(float explode, float explodePerLevel) {
  PVector origin;
  PVector normal; 
  PVector direction;

  int roll=-1;
  int planeRoll=(int)random(6);

  switch(planeRoll) {
  case 0:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);
    origin=new PVector(-50+100*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  case 1:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);
    origin=new PVector(0, -50+100*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break; 
  case 2:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);
    origin=new PVector(0, 0, -50+100*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 3:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);
    origin=new PVector(-50+100*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break;
  case 4:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);
    origin=new PVector(0, -50+100*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  default:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);
    origin=new PVector(0, 0, -50+100*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  }

  float shearAngle =15.0*(int)random(1.0, 4.0);
  return new Transformation(origin, normal, shearAngle, direction, SHEAR,explode, explodePerLevel);
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
  tree.draw((slices+1)*(0.5-0.55*cos(radians(0.2*frameCount))));
  hint(ENABLE_DEPTH_MASK);
}

void mousePressed(){
  init();
}
