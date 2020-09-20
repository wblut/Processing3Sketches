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
  float angle=radians(90);
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
  float displacement =25.0*(int)random(1.0, 5.0);
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




static int ROTATION=1;
static int TRANSLATION=0;
static int SHEAR=2;
static int STRETCH=3;

class Transformation {
  Transform T;
  Plane plane;
  PVector origin;
  PVector normal;
  PVector direction;
  PVector reverseDirection;
  float amount;
  int type;//0==translation, 1==rotation, 2==shear
  int level;

  //rotation or stretch
  Transformation(PVector origin, PVector axis, float angle, int type) {
    this.origin=origin.copy();
    this.normal=axis.copy();

    this.normal.normalize();
    this.plane = new Plane(this.origin, this.normal); 
    this.amount=angle; 
    this.type=type;
    assert(type==ROTATION|| type==STRETCH);
    this.direction=this.normal;
    this.reverseDirection=new PVector(-this.direction.x, -this.direction.y, -this.direction.z);
    this.level=0;
  }

  //translation or shear
  Transformation(PVector origin, PVector normal, float amount, PVector direction, int type) {
    this.origin=origin.copy();
    this.normal=normal.copy();
    this.normal.normalize();
    this.plane = new Plane(this.origin, this.normal); 
    this.type=type;
    assert(type==TRANSLATION || type==SHEAR);

    this.amount=amount; 
    this.direction =direction.copy();
    this.direction.normalize();
    this.reverseDirection=new PVector(-this.direction.x, -this.direction.y, -this.direction.z);
    this.level=0;
  }



  Transform getTransform(float f) {

    float fAmount=f*amount;
    T = new Transform(); 
    if (type==TRANSLATION) {
      T.addTranslate(fAmount, direction);
      T.addTranslate(f*(explode+level*explodePerLevel), normal);
    } else if (type==ROTATION) {
      T.addRotateAboutAxis(fAmount, origin, direction);
      T.addTranslate(f*(explode+level*explodePerLevel), normal);
    } else if (type==SHEAR) {
      T.addShear(origin, normal, direction, radians((float)fAmount));
      T.addTranslate(f*(explode+level*explodePerLevel), normal);
    } else if (type==STRETCH) {
      fAmount=1.0+f*(amount-1.0);
      T.addStretch(origin, normal, fAmount);
      T.addTranslate(f*(explode+level*explodePerLevel), normal);
    }
    return T;
  }

  Transform getInverseTransform(float f) {
    float fAmount=f*amount;
    T = new Transform(); 
    if (type==TRANSLATION) {
      T.addTranslate(-f*(explode+level*explodePerLevel), normal);
      T.addTranslate(fAmount, reverseDirection);
    } else if (type==ROTATION) {
      T.addTranslate(-f*(explode+level*explodePerLevel), normal);
      T.addRotateAboutAxis(fAmount, origin, reverseDirection);
    } else if (type==SHEAR) {
      T.addTranslate(-f*(explode+level*explodePerLevel), normal);
      T.addShear(origin, normal, reverseDirection, radians((float)fAmount));
    } else if (type==STRETCH) {
      fAmount=1.0+f*(amount-1.0);
      T.addTranslate(-f*(explode+level*explodePerLevel), normal);
      T.addStretch(origin, normal, 1.0/fAmount);
    }
    return T;
  }
}
