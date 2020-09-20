import java.util.Set;
import java.util.HashSet;
SliceTree tree;
int slices;
float phase;

float rotationChance;
float translationChance;
float shearChance;

Set<Integer> xRolls;
Set<Integer> yRolls;
Set<Integer> zRolls;

boolean freeze;
int counter;
float zoom;
float tx, ty;
PShader filter, post;
void setup() {
  fullScreen(P3D);
  smooth(16);
  noCursor();

  filter=loadShader("mirrorx.glsl");
  post=loadShader("vignette.glsl");

  init();
}

void init() {
  zoom=1.0;
  translationChance=random(1.0);
  rotationChance=random(1.0-translationChance);
  shearChance=random(1.0-translationChance-rotationChance);
  //stretchChance=1.0-translationChance-rotationChance-shearChance;
  slices=24;
  ArrayList<SliceBox> sliceBoxes=new ArrayList<SliceBox>();
  Transform T=new Transform();
  T.addRotateY(QUARTER_PI);
  T.addRotateX(radians(35.264));
  for (int i=-4; i<=4; i++) {
    SliceBox sliceBox;
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(i*40, 0, 0, 20, 300, 300, color(255));
    T.apply(sliceBox);
    sliceBoxes.add(sliceBox);
  }
 SliceBox sliceBox;
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(0, 0, 0, 100,100, 100, color(255));
    T.apply(sliceBox);
    sliceBoxes.add(sliceBox);
  tree=new SliceTree(sliceBoxes);
  xRolls=new HashSet<Integer>();
  yRolls=new HashSet<Integer>();
  zRolls=new HashSet<Integer>();
  int hue=(int)random(256);
  for (int r=0; r<slices; r++) {
    // colorMode(HSB);
    int col=color(r*4);//);
    //colorMode(RGB);
    slice(r, 7.35, 0.0, col);
  }
  counter=0;
  tx=ty=0.0;
  freeze=false;
}

void slice(int slicecount, float explode, float explodePerLevel, color col) {

  Transformation M;
  float roll=random(1.0);
  if (roll<translationChance) {
    M=sliceAndTranslate(explode, explodePerLevel);
  } else if (roll<rotationChance+translationChance) {
    M=sliceAndRotate(explode, explodePerLevel);
  } else  if (roll<rotationChance+translationChance+shearChance) {
    M=sliceAndShear(explode, explodePerLevel);
  } else {
    M=sliceAndStretch(explode, explodePerLevel);
  } 
  M.level=slicecount;
  tree.split(M, col);
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
  return new Transformation(origin, normal, angle, ROTATION, explode, explodePerLevel);
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
  return new Transformation(origin, normal, displacement, direction, TRANSLATION, explode, explodePerLevel);
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

    origin=new PVector(-150+300*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  case 1:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);

    origin=new PVector(0, -150+300*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break; 
  case 2:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);

    origin=new PVector(0, 0, -150+300*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 3:
    do {
      roll=(int)random(3, 18);
    } while (xRolls.contains(roll));
    xRolls.add(roll);

    origin=new PVector(-150+300*0.05*roll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break;
  case 4:
    do {
      roll=(int)random(3, 18);
    } while (yRolls.contains(roll));
    yRolls.add(roll);

    origin=new PVector(0, -150+300*0.05*roll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  default:
    do {
      roll=(int)random(3, 18);
    } while (zRolls.contains(roll));
    zRolls.add(roll);

    origin=new PVector(0, 0, -150+300*0.05*roll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  }

  float shearAngle =22.50;//15.0*(int)random(1.0, 4.0);
  return new Transformation(origin, normal, shearAngle, direction, SHEAR, explode, explodePerLevel);
}

Transformation sliceAndStretch(float explode, float explodePerLevel) {
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

  float  s =(random(100)<50)?1.0/1.5:1.5;
  return new Transformation(origin, normal, s, STRETCH, explode, explodePerLevel);
}

void draw() {
  background(255, 178, 45);


  // ortho();
  translate(width/2+tx, height/2+ty);
  rotateY(radians(0.4*constrain(counter-900, 0, 900)));
  //rotateX(radians(35.264));
  // rotateY(QUARTER_PI);
  directionalLight(255, 255, 255, 0, 0, -1);
  pointLight(200, 200, 200, 0, -550, 0);
  pointLight(200, 200, 200, -800, -300, 0);
  pointLight(200, 200, 200, 0, 0, 750);
  scale(zoom);
  // hint(DISABLE_DEPTH_MASK);
  noStroke();
  fill(0, 255-150*(0.5-0.50*cos(radians(0.2*counter))));
  tree.draw((slices+1)*(0.5-0.52*cos(radians(0.2*counter))));
  stroke(0);
  noFill();
  tree.draw((slices+1)*(0.5-0.52*cos(radians(0.2*counter))));
  // hint(ENABLE_DEPTH_MASK);
  if (!freeze) counter++;
  if (counter==1800) init();
  filter(filter);
  filter(post);
}
void keyPressed() {
  if (key==' ') {
    freeze=!freeze;
  } else if (key=='+') {
    zoom+=0.1;
  } else if (key=='-') {
    zoom-=0.1;
  } else if (key== CODED) {
    if (keyCode==UP) {
      ty-=10;
    } else if (keyCode==DOWN) {
      ty+=10;
    } else if (keyCode==RIGHT) {
      tx+=10;
    } else if (keyCode==LEFT) {
      tx-=10;
    }
  }
}
void mousePressed() {
  init();
}
