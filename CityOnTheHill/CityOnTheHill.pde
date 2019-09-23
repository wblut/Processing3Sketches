Box root;
int maxLevel;
int gap;
int nx, ny, nz, tmp;
int[] range;
 
void setup() {
  fullScreen(P3D);
  smooth();
  root=new Box(0, 0, 0, 200, 1200, 1200);
  maxLevel=0;
  gap=0;
  range=new int[]{root.cx-root.dx/2,root.cx+root.dx/2,root.cy-root.dy/2,root.cy+root.dy/2,root.cz-root.dz/2,root.cz+root.dz/2};
}
 
void draw() {
  background(220);
  smooth(16);
  ortho(-width/2, width/2, -height/2, height/2, 0.1, 100000);
  translate(width/2, height/2, -10000);
  rotate(PI/3.0);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  rotateX(asin(1.0/sqrt(3.0)));
  rotateY(QUARTER_PI);
  noStroke();
  translate(-(range[0]+range[1])/2,-(range[2]+range[3])/2,-(range[4]+range[5])/2);
  scale(0.5);
  root.draw();
}
 
void sliceAndDice(){
int roll=(int)random(6);//DICE
  switch(roll) {//SLICE
  case 0:
    root.splitAndTranslateX(20*(int)random(-15, 15), 10*(int)random(-5, 5), 10*(int)random(-5, 5));
    break;
  case 1:
    root.splitAndTranslateY(20*(int)random(-15, 15), 10*(int)random(-5, 5), 10*(int)random(-5, 5));
    break;
  case 2:
    root.splitAndTranslateZ(20*(int)random(-15, 15), 10*(int)random(-5, 5), 10*(int)random(-5, 5));
    break;
  case 3:
    root.splitAndRotateX(20*(int)random(-15, 15), 5*(int)random(-5, 5), 5*(int)random(-5, 5), (int)random(1, 3));
    break;
  case 4:
    root.splitAndRotateY(20*(int)random(-15, 15), 5*(int)random(-5, 5), 5*(int)random(-5, 5), (int)random(1, 3));
    break;
  default:
    root.splitAndRotateZ(20*(int)random(-15, 15), 5*(int)random(-5, 5), 5*(int)random(-5, 5), (int)random(1, 3));
  }
  root.getRange(range);
  maxLevel++;  
}
 
void mousePressed() {
  sliceAndDice();
}
 
class Box {
  Box parent;
  int cx, cy, cz;
  int dx, dy, dz;
  ArrayList<Box> children;
  int level;
  Box(int cx, int cy, int cz, int dx, int dy, int dz) {
    parent=null;
    this.cx=cx;
    this.cy=cy;
    this.cz=cz;
    this.dx=dx;
    this.dy=dy;
    this.dz=dz;
    children=new ArrayList<Box>();
    level=0;
  }
 
  void draw() {
    if (children.size()==0) {
      pushMatrix();
      translate(cx, cy, cz);
      box(dx, dy, dz);
      popMatrix();
    } else {
      if (children.size()>0) for (Box child : children) child.draw();
    }
  }
 
  void splitAndTranslateX(int x, int y, int z) {
    Box child1, child2;
    if (children.size()==0) {
      if (x<=cx-dx/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        child2.translateBox(gap, y, z);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (x>=cx+dx/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box((x+cx-dx/2)/2, cy, cz, x-cx+dx/2, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box((cx+dx/2+x)/2, cy, cz, cx+dx/2-x, dy, dz);
        child2.translateBox(gap, y, z);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndTranslateX(x, y, z);
    }
  }
 
  void splitAndRotateX(int x, int y, int z, int r) {
    Box child1, child2;
    if (children.size()==0) {
      if (x<=cx-dx/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        for (int i=0; i<r; i++) {
          child2.rotateBoxX(y, z);
        }
        child2.translateBox(gap, 0, 0);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (x>=cx+dx/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box((x+cx-dx/2)/2, cy, cz, x-cx+dx/2, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box((cx+dx/2+x)/2, cy, cz, cx+dx/2-x, dy, dz);
        for (int i=0; i<r; i++) {
          child2.rotateBoxX(y, z);
        }
        child2.translateBox(gap, 0, 0);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndRotateX(x, y, z, r);
    }
  }
 
  void splitAndTranslateY(int y, int x, int z) {
    Box child1, child2;
    if (children.size()==0) {
      if (y<=cy-dy/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        child2.translateBox(x, gap, z);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (y>=cy+dy/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box(cx, (y+cy-dy/2)/2, cz, dx, y-cy+dy/2, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box(cx, (cy+dy/2+y)/2, cz, dx, cy+dy/2-y, dz);
        child2.translateBox(x, gap, z);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndTranslateY(y, x, z);
    }
  }
 
  void splitAndRotateY(int y, int x, int z, int r) {
    Box child1, child2;
    if (children.size()==0) {
      if (y<=cy-dy/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        for (int i=0; i<r; i++) {
          child2.rotateBoxY(x, z);
        }
        child2.translateBox(0, gap, 0);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (y>=cy+dy/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box(cx, (y+cy-dy/2)/2, cz, dx, y-cy+dy/2, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box(cx, (cy+dy/2+y)/2, cz, dx, cy+dy/2-y, dz);
        for (int i=0; i<r; i++) {
          child2.rotateBoxY(x, z);
        }
        child2.translateBox(0, gap, 0);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndRotateY(y, x, z, r);
    }
  }
 
  void splitAndTranslateZ(int z, int x, int y) {
    Box child1, child2;
    if (children.size()==0) {
      if (z<=cz-dz/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        child2.translateBox(x, y, gap);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (z>=cz+dz/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box(cx, cy, (z+cz-dz/2)/2, dx, dy, z-cz+dz/2);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box(cx, cy, (cz+dz/2+z)/2, dx, dy, cz+dz/2-z);
        child2.translateBox(x, y, gap);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndTranslateZ(z, x, y);
    }
  }
 
  void splitAndRotateZ(int z, int x, int y, int r) {
    Box child1, child2;
    if (children.size()==0) {
      if (z<=cz-dz/2) {
        child2=new Box(cx, cy, cz, dx, dy, dz);
        for (int i=0; i<r; i++) {
          child2.rotateBoxZ(x, y);
        }
        child2.translateBox(0, 0, gap);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      } else if (z>=cz+dz/2) {
        child1=new Box(cx, cy, cz, dx, dy, dz);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
      } else {
        child1=new Box(cx, cy, (z+cz-dz/2)/2, dx, dy, z-cz+dz/2);
        child1.parent=this;
        child1.level=level+1;
        children.add(child1);
        child2=new Box(cx, cy, (cz+dz/2+z)/2, dx, dy, cz+dz/2-z);
        for (int i=0; i<r; i++) {
          child2.rotateBoxZ(x, y);
        }
        child2.translateBox(0, 0, gap);
        child2.parent=this;
        child2.level=level+1;
        children.add(child2);
      }
    } else {
      if (children.size()>0) for (Box child : children) child.splitAndRotateZ(z, x, y, r);
    }
  }
 
  void translateBox(int x, int y, int z) {
    cx+=x;
    cy+=y;
    cz+=z;
  }
 
  void rotateBoxZ(int rcx, int rcy) {
    nx=cx-rcx;
    ny=cy-rcy;
    cx=-ny+rcx;
    cy=nx+rcy;
    tmp=dx;
    dx=dy;
    dy=tmp;
  }
 
  void rotateBoxY(int rcx, int rcz) {
    nx=cx-rcx;
    nz=cz-rcz;
    cx=-nz+rcx;
    cz=nx+rcz;
    tmp=dx;
    dx=dz;
    dz=tmp;
  }
 
  void rotateBoxX(int rcy, int rcz) {
    nz=cz-rcz;
    ny=cy-rcy;
    cz=-ny+rcz;
    cy=nz+rcy;
    tmp=dz;
    dz=dy;
    dy=tmp;
  }
 
  void getRange(int[] range){
    if (children.size()==0) {
      range[0]=min(range[0],cx-dx/2);
      range[1]=max(range[1],cx+dx/2);
      range[2]=min(range[2],cy-dy/2);
      range[3]=max(range[3],cy+dy/2);
      range[4]=min(range[4],cz-dz/2);
      range[5]=max(range[5],cz+dz/2);
 
    } else {
      if (children.size()>0) for (Box child : children) child.getRange(range);
    }  
  }
}
