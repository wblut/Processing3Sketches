import wblut.math.*;
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.nurbs.*;
import wblut.processing.*;
import java.util.*;

boolean ORTHOROT;
boolean ORTHO;

WB_Ease easeIn,easeOut1R,easeOut1T,easeOut2R,easeOut2T,easeInOut;
FragmentTree fragmentTree;
WB_Render3D render;

int maxLevel;

int numFrames;
int frameCounter;
float hueshift;
int slices;
float rotationDirection,  rotationRange;
int rotationMode;
WB_AABB AABB;

float explode;
HE_Mesh fragment;
int hueDirection;
WB_Point shift;

public void setup() {
  size(800, 800, P3D);
  smooth(16);
  noCursor();
  colorMode(HSB);
  render=new WB_Render3D(this);
  easeIn=WB_Ease.getSine();
  easeInOut=WB_Ease.getSine();
  strokeWeight(2.0);
  numFrames=540;
  init();
}

void init() {
  ORTHO=true;
  ORTHOROT=ORTHO?random(100)<50:false;
  rotationRange=(int)random(1,3)*HALF_PI;
  rotationDirection=((random(100)<50)?-1:1); 
  rotationMode=(int)random(2);
  createMesh();
  hueshift=random(256.0);
  hueDirection=random(100)<50?-1:1;
  easeOut2R= random(100)<33.33?WB_Ease.getElastic(1.0,0.3):random(100)<50.0?WB_Ease.getBounce():WB_Ease.getSine();
  easeOut2T= random(100)<50?WB_Ease.getQuint():WB_Ease.getBounce();
  easeOut1R= random(100)<50?WB_Ease.getElastic(1.0,0.3):WB_Ease.getSine();
  easeOut1T= random(100)<50?WB_Ease.getElastic(1.0,0.3):WB_Ease.getQuint();//EaseElastic(1.0, 0.6);//getElastic();
  slices=(int)random(8,14);
  explode=random(100.0)<50?0.0:20.0;
  while(maxLevel<slices){
    fragmentTreeSplit();
    AABB=fragmentTree.determineAABB();
  }
  frameCounter=0;
  shift=new WB_Point(); 
}

void createMesh() {
  HE_Mesh mesh = new HE_Mesh(new HEC_Box(250, 250, 250, 1, 1, 1));
  HE_FaceIterator fItr = mesh.fItr();
  HE_Face f;
  while (fItr.hasNext()) {
    f=fItr.next();
    f.setColor(color(0));
  }
  fragmentTree = new FragmentTree(mesh);
  maxLevel=0;
  AABB=fragmentTree.determineAABB(0.0, 0);
}

void fragmentTreeSplit() {
  Movement M;
  WB_Plane P;
  int roll=(int)random(8);
  int angleRoll=random(100)<50?-1:1;
  float angle=angleRoll*random(PI/6.0, PI/1.5);
  float movement =random(20.0, 100.0);
  switch(roll) {
  case 0:
    int xRoll=(int)random(4, 17);
    P = new WB_Plane(AABB.getMin(0)+AABB.getWidth()*0.05*xRoll, 7.5*(int)random(-9, 9), 7.5*(int)random(-9, 9), random(100)<50?1:-1, 0, 0);
    M=new Movement(P, angle, false);
    break;
  case 1:
    int yRoll=(int)random(4, 17);
    P = new WB_Plane(7.5*(int)random(-9, 9), AABB.getMin(1)+AABB.getHeight()*0.05*yRoll, 7.5*(int)random(-9, 9), 0, random(100)<50?1:-1, 0);
    M=new Movement(P, angle, false);
    break;
  case 2:
    int zRoll=(int)random(4, 17);
    P = new WB_Plane(7.5*(int)random(-9, 9), 7.5*(int)random(-9, 9), AABB.getMin(2)+AABB.getDepth()*0.05*zRoll, 0, 0, random(100)<50?1:-1);
    M=new Movement(P, angle, false);
    break;
  case 3:
    P = new WB_Plane(7.5*(int)random(-9, 9), 7.5*(int)random(-9, 9), 7.5*(int)random(-9, 9), random(-1, 1), random(-1, 1), random(-1, 1));
    M=new Movement(P, angle, false);
    break;
  case 4:
    xRoll=(int)random(3, 18);
    P = new WB_Plane(AABB.getMin(0)+AABB.getWidth()*0.05*xRoll, 0, 0, random(100)<50?1:-1, 0, 0);
    M=new Movement(P, movement, new WB_Vector(0, random(-1,1), random(-1,1)));
    break;
  case 5:
    yRoll=(int)random(3, 18);
    P = new WB_Plane(0, AABB.getMin(1)+AABB.getHeight()*0.05*yRoll, 0, 0, random(100)<50?1:-1, 0);
    M=new Movement(P, movement, new WB_Vector(random(-1,1), 0,random(-1,1)));
    break;
  case 6:
    zRoll=(int)random(3, 18);
    P = new WB_Plane(0, 0, AABB.getMin(2)+AABB.getDepth()*0.05*zRoll, 0, 0, random(100)<50?1:-1);
    M=new Movement(P, movement, new WB_Vector(random(-1,1),random(-1,1),0));
    break;
  default:
    P = new WB_Plane(AABB.getMin(0)+AABB.getDepth()*0.05*(int)random(3, 18), AABB.getMin(1)+AABB.getDepth()*0.05*(int)random(3, 18), AABB.getMin(2)+AABB.getDepth()*0.05*(int)random(3, 18), random(-1, 1), random(-1, 1), random(-1, 1));
    M=new Movement(P, movement, true);
  }
  maxLevel++;
  M.level=maxLevel;
  fragmentTree.split(M);
}

void draw() {
  if (frameCount<numFrames/2) {
    frameCounter=frameCount;
  } else if (frameCount>numFrames/2+19) {
    frameCounter=frameCount-19;
  } else {
    frameCounter=numFrames/2;
  }
  if (ORTHO) ortho();
  translate(width / 2, height / 2);
  float phase = map(frameCounter-1 , 0, numFrames, 0, 1);
  float phase2 = map(frameCount-1 , 0, (numFrames+20), 0, 1);
  float angle=phase*TWO_PI;
  float f=(0.5-0.5*cos(angle))*maxLevel;
  background(50);//(hueshift+128)%256,40,50);
  AABB=fragmentTree.determineAABB(f, frameCounter-1);
  shift.mulAddMulSelf(0.5, 0.5, AABB.getCenter());
  pushMatrix();  
  fill(0);
  if (ORTHOROT) {
    rotateX(asin(1.0/sqrt(3.0)));
    rotateY(QUARTER_PI);
  }
  rotate(phase2);
  translate(-shift.xf(), -shift.yf(), -shift.zf());
  fragmentTree.draw(f, frameCounter-1);
  popMatrix();

  if (frameCounter==numFrames) {
    frameCount=0;
    maxLevel=0;
    init();
  }
}

void rotate(float phase2) {
   if (rotationMode==0) {
    if (phase2>0.5) {
     
      rotateX(rotationDirection*(float)easeInOut.easeInOut(2*phase2-1.0)*rotationRange);
    } 
  } else if (rotationMode==1) {
    if (phase2>0.5) {
      
      rotateY(rotationDirection*(float)easeInOut.easeInOut(2*phase2-1.0)*rotationRange);
    }
  } 
}

 
 class FragmentTree {
  Fragment root;

  FragmentTree(final HE_Mesh mesh) {
    root = new Fragment(mesh);
  }

  void split(final Movement M) {
    root.split(M,random(2,6)*10);
  }

  WB_AABB determineAABB(double f, int counter) {
    WB_AABB aabb=new WB_AABB();
    root.determineAABB(f, aabb, counter);
    return aabb;
  }

  WB_AABB determineAABB() {
    WB_AABB aabb=new WB_AABB();
    root.determineAABB(aabb);
    return aabb;
  }

  void draw(final double f, int counter) {
    root.draw(f, counter);
  }

}

class Fragment {
  Fragment parent;
  Fragment child0, child1;
  Movement parentToChild;
  HE_Mesh mesh;
  HE_Mesh invTmesh;
  HE_Mesh dynMesh;
  int level;

  Fragment(final HE_Mesh mesh) {
    this.mesh = mesh.get();
    invTmesh = mesh.get();
    dynMesh = mesh.get();
    parentToChild = null;
    parent = null;
    child0 = null;
    child1 = null;
    level = 0;
  }

  Fragment(final HE_Mesh mesh,  final Fragment parent, final Movement parentToChild) {
    this.mesh = mesh.get();
    this.parentToChild = parentToChild;
    this.parent = parent;
    invTmesh = mesh.get();
    Fragment p = this;
    do {
      if ( p.parentToChild!=null) {
        final WB_Transform3D T = p.parentToChild.getInvT(1.0);
        invTmesh.transformSelf(T);
      }
      p = p.parent;
    } while (p != null);
    dynMesh = mesh.get();
    level=parent.level+1;
    
  }

  void split(Movement M, double sep) {
    if ((child0 == null) && (child1 == null)) {
      HE_Mesh split=mesh.get();
      split.removeSelection("caps");
      HEMC_SplitMesh sm = new HEMC_SplitMesh().setPlane(M.P).setMesh(split);
      HE_MeshCollection result = sm.create();
      HE_Mesh submesh0=result.getMesh(0).get();
      HE_Mesh submesh1=result.getMesh(1).get();
      float hue=(hueshift+256+hueDirection*(int)maxLevel*8)%256;
      if (submesh0.getNumberOfVertices() > 0 ) {
        final HE_FaceIterator fitr = submesh0.getSelection("caps").fItr();
        while (fitr.hasNext()) {
          fitr.next().setColor(color(hue, 255, 255));
        }
        child0 = new Fragment(submesh0, this, null); 
      }
      if (submesh1.getNumberOfVertices() > 0) {
        final HE_FaceIterator fitr = submesh1.getSelection("caps").fItr();
        while (fitr.hasNext()) {
          fitr.next().setColor(color(hue, 255, 255));
        }
        submesh1.transformSelf(M.getT(1.0));
        child1 = new Fragment(submesh1, this, M);
      }
    } else {
      if (child0 != null) {
        child0.split(M,sep);
      }
      if (child1 != null) {
        child1.split(M,sep);
      }
     

    }
  }

  void determineAABB(final double f, WB_AABB aabb, int counter) {
    if ((child0 == null) && (child1 == null)) {
      aabb.expandToInclude(getMesh(f, counter).getAABB());
    } else {
      if (child0 != null) {
        child0.determineAABB(f, aabb, counter);
      }
      if (child1 != null) {
        child1.determineAABB(f, aabb, counter);
      }
    }
  }

  void determineAABB(WB_AABB aabb) {
    if ((child0 == null) && (child1 == null)) {
      aabb.expandToInclude(mesh.getAABB());
    } else {
      if (child0 != null) {
        child0.determineAABB( aabb);
      }
      if (child1 != null) {
        child1.determineAABB( aabb);
      }
    }
  }

  void draw(final double f, int counter) {
    if (((child0 == null) && (child1 == null))||(f-0.01)<=level) {
      final HE_Mesh m = getMesh(f, counter);
      pushMatrix();
      noStroke();
      fill(255);
      render.drawFacesFC(m);
      popMatrix();
    } else {
      if (child0 != null) {
        child0.draw(f, counter);
      }
      if (child1 != null) {
        child1.draw(f, counter);
      }
    }
  }

  HE_Mesh getMesh(double f, int counter) {
    if (f<=0.01) {
      return invTmesh;
    } else if (f>=level-0.01) {
      return mesh;
    } else {
      Fragment p = this;
      float fracf;
      WB_Transform3D T=new WB_Transform3D();
      do {
        if (p.parentToChild!=null) {
          fracf=constrain((float)(p.level-f), 0.0, 1.0);
          if (counter<numFrames/2) {
            fracf=1.0-fracf;
          }

          if (fracf<=0.5) {
            fracf=(float)easeIn.easeInOut(fracf);
          } else {
            fracf=(counter<numFrames/2)? ((p.parentToChild.translation)?(float)easeOut1T.easeInOut(fracf):(float)easeOut1R.easeInOut(fracf)):((p.parentToChild.translation)?(float)easeOut2T.easeInOut(fracf):(float)easeOut2R.easeInOut(fracf));
          }

          if (counter<numFrames/2) {
            fracf=1.0-fracf;
          }
          T.addTransform(p.parentToChild.getInvT(fracf));
        }
        p = p.parent;
      } while (p != null && f<p.level);
      HE_VertexIterator sItr=mesh.vItr();
      HE_VertexIterator tItr=dynMesh.vItr();
      WB_Point vertex=new WB_Point();
      while (sItr.hasNext()) {
        T.applyAsPointInto(sItr.next(), tItr.next());
      }
      return dynMesh;
    }
  }

}



class Movement {
  WB_Plane P;
  WB_Transform3D T;
  WB_Point origin;
  WB_Vector direction;
  WB_Vector reverseDirection;
  double amount;
  boolean translation;
  int level;

  Movement() {
  }

  Movement(WB_Plane P) {
    this.P=P.get();
    this.P.flipNormal();
    this.translation=true;
    this.amount=0.0; 
    this.origin=this.P.getOrigin();
    this.direction = new WB_Vector(1, 0, 0);
    this.reverseDirection=this.direction.mul(-1);
    this.level=0;
  }

  Movement(WB_Plane P, double amount, boolean translation) {
    this.P=P.get();
    this.translation=translation;
    this.amount=amount; 
    this.origin=this.P.getOrigin();
    if (translation) {
      this.direction = this.P.getNormal().cross(new WB_Vector(random(-1, 1), random(-1, 1), random(-1, 1)));
      this.direction.normalizeSelf();
    } else {
      this.direction=this.P.getNormal();
    }
    this.reverseDirection=this.direction.mul(-1);
    this.level=0;
  }

  Movement(WB_Plane P, double amount, WB_Coord shift) {
    this.P=P.get();
    this.translation=true;
    this.amount=amount; 
    this.origin=this.P.getOrigin();
    this.direction = new WB_Vector(shift);
    this.direction.normalizeSelf();
    this.reverseDirection=this.direction.mul(-1);
    this.level=0;
  }

  WB_Transform3D getT(double f) {
    double fAmount=f*amount;
    T = new WB_Transform3D(); 
    if (translation) {
      T.addTranslate(direction.mul(fAmount));
      T.addTranslate(P.getNormal().mul(-f*f*explode));
    } else {
      T.addRotateAboutAxis(fAmount, origin, direction);
      T.addTranslate(P.getNormal().mul(-f*f*explode));
    }
    return T;
  }

  WB_Transform3D getInvT(double f) {
    double fAmount=f*amount;
    T = new WB_Transform3D(); 
    if (translation) {
      T.addTranslate(P.getNormal().mul(f*f*explode));
      T.addTranslate(reverseDirection.mul(fAmount));
    } else {
      T.addTranslate(P.getNormal().mul(f*f*explode));
      T.addRotateAboutAxis(fAmount, origin, reverseDirection);
    }
    return T;
  }

  Movement inverse() {
    Movement rev=new Movement(P);
    rev.P=P.get();
    rev.origin=new WB_Point(origin);
    rev.direction=new WB_Vector(reverseDirection);
    rev.reverseDirection=new WB_Vector(direction);
    rev.amount=amount;
    rev.translation=translation;
    rev.level=level;
    return rev;
  }
}
