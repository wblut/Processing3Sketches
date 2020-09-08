SliceTree tree;
int slices;
float rotationChance;
float translationChance;
float shearChance;
float explode;
float explodePerLevel;
float phase;
boolean freeze;
int counter;
int numFrames;
float zoom;
float tx, ty, ax, ay, az;
float ttx, tty, ttz;
float sscale;
boolean gui;
PShader filter, post;

void setup() {
  fullScreen(P3D);
  smooth(16);
  noCursor();
  filter=loadShader("mirrorx.glsl");
  post=loadShader("vignette.glsl");
  explode=4;
  numFrames=1800;
  init();
}

void init() {
  filter=(random(100)<66.6)?(random(100)<50.0)?loadShader("mirrorx.glsl"):loadShader("mirrory.glsl"):loadShader("mirrorxy.glsl");
  int seed=(int)random(10000000);
  println(String.format("%08d", seed));
  randomSeed(seed);
  initialGeometry();
  translationChance=0.32;
  rotationChance=0.32;
  shearChance=0.1;
  //stretchChance=1.0-translationChance-rotationChance-shearChance;
  slices=25;
  tree=new SliceTree(initialGeometry());
  for (int r=0; r<slices; r++) {
    slice(r, color(0), color(0));
  }
  counter=0;
  zoom=1.0;
  tx=ty=ax=ay=az=0.0;
  freeze=false;
  gui=true;
}

ArrayList<SliceBox> initialGeometry() {
  ArrayList<SliceBox> sliceBoxes=new ArrayList<SliceBox>();
  for (int i=-5; i<=5; i++) {
    SliceBox sliceBox;
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(0, i*30, 0, 310, abs(i)==5?10:10*(int)random(1.0, 3.0), 620, color(0));
    if (random(100)<50||abs(i)==5) sliceBoxes.add(sliceBox);
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(0, 0, i*60, 310, 310, abs(i)==5?10:10*(int)random(1.0, 3.0), color(0));
    if (random(100)<50||abs(i)==5) sliceBoxes.add(sliceBox);
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize(0, 0, i*60+30, 310, 310, 10*(int)random(1.0, 3.0), color(0));
    if (random(100)<50) sliceBoxes.add(sliceBox);
    sliceBox=new SliceBox();
    sliceBox.createBoxWithCenterAndSize( i*30, 0, 0, abs(i)==5?10:10*(int)random(1.0, 3.0), 310, 620, color(0));
    if (random(100)<50||abs(i)==5) sliceBoxes.add(sliceBox);
  }

  tree=new SliceTree(sliceBoxes);
  return sliceBoxes;
}

void slice(int slicecount, color col, color col2) {
  Transformation M;
  int trial=0;
  do {

    float sliceRoll=random(1.0);
    if (sliceRoll<translationChance) {
      M=sliceAndTranslate();
    } else if (sliceRoll<rotationChance+translationChance) {
      M=sliceAndRotate();
    } else  if (sliceRoll<rotationChance+translationChance+shearChance) {
      M=sliceAndShear();
    } else {
      M=sliceAndStretch();
    }
    trial++;
  } while (tree.minDistance(M.plane)<5 && trial<20);

  M.level=slicecount;
  tree.split(M, col, col2);
}

Transformation sliceAndRotate() {
  PVector origin;
  PVector normal; 
  int dirRoll=(int)random(3);
  float posRoll=random(-150, 150);
  switch(dirRoll) {
  case 0:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 1:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    break;
  default:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1);
  }
  float angle=random(100)<0?QUARTER_PI:HALF_PI;
  return new Transformation(origin, normal, angle, ROTATION);
}

Transformation sliceAndTranslate() {
  PVector origin;
  PVector normal; 
  PVector direction;
  float posRoll=random(-150, 150);
  int planeRoll=(int)random(6);
  switch(planeRoll) {
  case 0:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  case 1:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break; 
  case 2:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 3:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break;
  case 4:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  default:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  }
  float displacement =50.0*(int)random(1.0, 5.0);
  return new Transformation(origin, normal, displacement, direction, TRANSLATION);
}


Transformation sliceAndShear() {
  PVector origin;
  PVector normal; 
  PVector direction;
  float posRoll=random(-150, 150);
  int planeRoll=(int)random(6);
  switch(planeRoll) {
  case 0:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  case 1:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break; 
  case 2:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 3:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    direction=new PVector(0, 0, random(100)<50?1:-1);
    break;
  case 4:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    direction=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  default:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1); 
    direction=new PVector(0, random(100)<50?1:-1, 0);
    break;
  }
  float shearAngle =30;
  return new Transformation(origin, normal, shearAngle, direction, SHEAR);
}

Transformation sliceAndStretch() {
  PVector origin;
  PVector normal; 
  int dirRoll=(int)random(3);
  float posRoll=random(-150, 150);
  switch(dirRoll) {
  case 0:
    origin=new PVector(posRoll, 0, 0);
    normal=new PVector(random(100)<50?1:-1, 0, 0);
    break;
  case 1:
    origin=new PVector(0, posRoll, 0);
    normal=new PVector(0, random(100)<50?1:-1, 0);
    break;
  default:
    origin=new PVector(0, 0, posRoll);
    normal=new PVector(0, 0, random(100)<50?1:-1);
  }
  float  s =sqrt(2.0);
  s=(random(100)<50)?1.0/s:s;
  return new Transformation(origin, normal, s, STRETCH);
}

void gui() {
  int firstLine=25;
  int nextLine=15;
  int line=firstLine;
  if (gui) {
    fill(255);
    text("Toggle time: spacebar", 25, line); 
    text("When frozen, rewind/forward: f/F ("+counter+")", 25, line+=nextLine); 
    text("When frozen, rotate X: x/X + ("+ax+")", 25, line+=2*nextLine);
    text("When frozen, rotate Y: y/Y + ("+ay+")", 25, line+=nextLine);
    text("When frozen, rotate image: z/Z +("+az+")", 25, line+=nextLine);
    text("Zoom: +/-", 25, line+=2*nextLine); 
    text("Center: arrow keys", 25, line+=nextLine); 
    text("Toggle controls: g", 25, line+=2*nextLine);
    text("Reset: n", 25, line+=nextLine); 
    noFill();
    stroke(255, 0, 0);
    rect(96, 96, 961-96-96, 961-96-96);
  }
}

void draw() {
  float phase=0.5-0.52*cos(radians(180.0/numFrames*counter));
  background(51, 32, 6);
  translate(width/2+tx, height/2+ty);
  rotateZ(radians(180+az));
  rotateX(radians(ax));
  rotateY(radians(ay+map(counter, 0, numFrames/2, 0, 360)));
  scale(zoom);
  tree.setPhase((slices+1)*phase);
  float[] extents=tree.getExtents();
  ttx=0.95*ttx-0.025*(extents[0]+extents[3]);
  tty=0.95*tty-0.025*(extents[1]+extents[4]);
  ttz=0.95*ttz-0.025*(extents[2]+extents[5]);
  sscale=min(1.0, min(1000.0/(extents[3]-extents[0]), 1000.0/(extents[4]-extents[1]), 1000/(extents[5]-extents[2])));
  scale(sscale);
  translate(ttx, tty, ttz);
  strokeWeight(1.0/(zoom*sscale));
  hint(DISABLE_DEPTH_MASK);
 stroke(255, 160, 40, 55);
  fill(0, 85+170*sq(2.0*map(counter, 0, numFrames, 0, 1)-1.0));
  tree.draw();
  
  filter(filter);

  if (!freeze) counter++;
  if (counter==numFrames) {
    init();
  }
}

void keyPressed() {
  if (key==' ') {
    freeze=!freeze;
    ax=0;
    ay=0;
    az=0;
  } else if (key=='n') {
    init();
  } else if (key=='s') {
    // drawHires();
    // hires.save("hires.png");
  } else if (key=='g') {
    gui=!gui;
  } else if (key=='f') {

    if (freeze) {
      counter=max(counter-5, 0);
      tree.bufferedF=Float.NaN;
    }
  } else if (key=='F') {

    if (freeze) {
      counter=min(counter+5, 1800);
      tree.bufferedF=Float.NaN;
    }
  } else if (key=='x') {
    if (freeze) {
      ax-=5;
      if (ax<=-180) ax+=360;
    }
  } else if (key=='X') {
    if (freeze) {
      ax+=5;
      if (ax>180) ax-=360;
    }
  } else if (key=='y') {
    if (freeze) {
      ay-=5;
      if (ay<=-180) ay+=360;
    }
  } else if (key=='Y') {
    if (freeze) {
      ay+=5;
      if (ay>180) ay-=360;
    }
  } else if (key=='z') {
    if (freeze) {
      az-=5;
      if (az<=-180) az+=360;
    }
  } else if (key=='Z') {
    if (freeze) {
      az+=5;
      if (az>180) az-=360;
    }
  } else if (key=='+') {
    zoom+=0.05;
  } else if (key=='-') {
    zoom-=0.05;
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
