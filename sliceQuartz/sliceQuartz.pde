ArrayList<Plane> majorPlanes;
ArrayList<Plane> minorPlanes;
SliceBox stock, crystal;

void setup() {
  size(1000, 1000, P3D);
  smooth(16);
  create();
}

void create() {
  majorPlanes = new ArrayList<Plane>();
  minorPlanes = new ArrayList<Plane>();
  stock=new SliceBox();
  
  //Create a slightly irregular rectangular prism wit N sides, radius varying between 90-110% radius and a "stock height" of 1.6*height;
  float radius=120;
  float prismHeight=500;
  int N=6;
  stock.createPrismWithCenterRadiusRangeAndHeight(N, 0, 0, 0, 0.9*radius, 1.1*radius, 1.6*prismHeight);
  
  //Carve a crystal from the stock, by slicing it with an "umbrella" of planes
 
  crystal=stock.copy();
  //Hieght of origin of slicing planes
  float heightSpread=20;
  //Downward slope of the slicing planes
  float inclination=38;
  float inclinationSpread=10;
  //Radial offset of slicing planes
  float penetration=0.7*radius;
  float penetrationSpread=0;
  //Rotation of slicing plan around height axis of stock
  float rotation=0;
  float rotationSpread=30;

  // Major facets, top and bottom
  carveCrystal(crystal, radius, N, 0.5*prismHeight, heightSpread, inclination, inclinationSpread, penetration, penetrationSpread, rotation, rotationSpread, false, majorPlanes);
  carveCrystal(crystal, radius, N, 0.5*prismHeight, heightSpread, inclination, inclinationSpread, penetration, penetrationSpread, rotation, rotationSpread, true, majorPlanes);

  //Minor facets, top and bottom
  penetration=0.5*radius;//less deep
  prismHeight-=random(0.1, 0.3)*radius;//a bit lower
  rotation=180.0/N;// half a division rotated
  carveCrystal(crystal, radius, N, 0.5*prismHeight, heightSpread, inclination, inclinationSpread, penetration, penetrationSpread, rotation, rotationSpread, false, minorPlanes);
  carveCrystal(crystal, radius, N, 0.5*prismHeight, heightSpread, inclination, inclinationSpread, penetration, penetrationSpread, rotation, rotationSpread, true, minorPlanes);
crystal.save(sketchPath("output.obj"));
}

void carveCrystal(SliceBox crystal, float radius, int N, float height, float heightSpread, float inclination, float inclinationSpread, float penetration, float penetrationSpread, float rotation, float rotationSpread, boolean invert, ArrayList<Plane> planes) {

  float dInc, dH, dRot, dPen;
  PVector normal;
  PVector origin;

  for (int i=0; i<N; i++) {
    
    //start with horizonatl plane
    normal=new PVector(0, invert?-1:1, 0);
    
    
    //tilt it downwards
    dInc=random(-inclinationSpread, inclinationSpread);
    float angle=radians(inclination+dInc);
    float dy=cos(angle)*normal.y-sin(angle)*normal.z;
    float dz=sin(angle)*normal.y+cos(angle)*normal.z;
    normal.y=dy;
    normal.z=dz;
    
    //move it to its height
    dH=random(-heightSpread, heightSpread);
    origin=new PVector(0, invert?-radius:radius, invert?-height-dH:height+dH);

    //rotate around height axis
    dRot=random(-rotationSpread, rotationSpread);
    angle=radians(i*360/N+rotation+dRot);
    float dx=cos(angle)*normal.x-sin(angle)*normal.y;
    dy=sin(angle)*normal.x+cos(angle)*normal.y;
    normal.x=dx;
    normal.y=dy;    
    float ox=cos(angle)*origin.x-sin(angle)*origin.y;
    float oy=sin(angle)*origin.x+cos(angle)*origin.y;
    origin.x=ox;
    origin.y=oy;

    //shift it inwards
    dPen=random(-penetrationSpread, penetrationSpread);
    planes.add(new Plane(origin, normal).offset(-penetration-dPen+2));
    crystal.slice(new Plane(origin, normal), -penetration-dPen);
  }
}


void draw() {
  background(240);
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));

  hint(ENABLE_DEPTH_MASK);
  strokeWeight(1);
  stroke(255,0,0);
  noFill();
  stock.draw();
  
  stroke(0);
  fill(255);
  crystal.draw();

  hint(DISABLE_DEPTH_MASK);
  strokeWeight(1);
  stroke(255, 0, 0, 100);
  fill(255, 0, 0, 50);
  for (Plane P : majorPlanes) {
    P.draw(400);
  }
  stroke(120, 0, 0, 100);
  fill(120, 0, 0, 50);
  for (Plane P : minorPlanes) {
    P.draw(200);
  }
}



void mousePressed() {
  create();
}
