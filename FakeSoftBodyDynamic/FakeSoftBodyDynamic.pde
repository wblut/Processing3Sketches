import wblut.math.*;
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.nurbs.*;
import wblut.processing.*;
import java.util.*;

WB_Render3D render;
List<Sphere> spheres;

int num;
void setup() {
  fullScreen(P3D);
  smooth(8);
  render=new WB_Render3D(this);
  WB_PointGenerator pg=new WB_RandomRectangle().setSize(800, 800);
  spheres=new ArrayList<Sphere>();
  num=100;

  for (int i=0; i<num; i++) {
    boolean enclosed=false;
    float R;
    WB_Point p;
    do {
      R=random(16, 32);
      p=pg.nextPoint();
      for (Sphere S : spheres) {
        double d2=WB_Vector.sub(p, S.center).getSqLength3D();
        enclosed=d2<S.radius*S.radius || d2<R*R;
        if (enclosed) break;
      }
    } while (enclosed);
    spheres.add(new Sphere( p, R));
  }
 // updateSpheres();
  processIntersections();
}

void draw() {
  background(15);
  translate(width/2, height/2);
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  lights();
  scale(1, -1, 1);

  noStroke();
  for (Sphere S : spheres) {
    render.drawFaces(S.mesh);
  }
  stroke(240);
  for (Sphere S : spheres) {
    render.drawEdges(S.mesh);
  }
   updateSpheres();
  processIntersections();
}

void updateSpheres() {
  Sphere S1, S2;
  WB_Vector[] disp=new WB_Vector[num];
  for (int i=0; i<num; i++) {
    disp[i]=new WB_Vector(0,random(0.5,1.5),0);
  }
  for (int i=0; i<num; i++) {
    S1=spheres.get(i);
    for (int j=i+1; j<num; j++) {
      S2=spheres.get(j);
      WB_Vector d = WB_Vector.sub(S2.center, S1.center);
      double dist = d.normalizeSelf();
      double R1 = S1.radius;
      double R2 = S2.radius;
      double disc = dist * dist - R2 * R2 + R1 * R1;
      disc *= disc;
      disc = 4 * dist * dist * R1 * R1 - disc;
      if (disc < 0) {
        continue;
      }
      double x = (dist * dist - R2 *R2 + R1 * R1) / (2.0 * dist);
      WB_Point p=WB_Point.addMul(S1.center, x, d);
      disp[i].addMulSelf(-1.0, d);
      disp[j].addMulSelf(1.0, d);
    }
  }
  for (int i=0; i<num; i++) {
    spheres.get(i).center.addSelf(disp[i]);
    spheres.get(i).resetMesh();
  }
}

void processIntersections() {
  Sphere S1, S2;
  WB_Plane P;
  for (int i=0; i<num; i++) {
    S1=spheres.get(i);
    for (int j=i+1; j<num; j++) {
      S2=spheres.get(j);
      WB_Vector d = WB_Vector.sub(S2.center, S1.center);
      double dist = d.normalizeSelf();
      double R1 = S1.radius;
      double R2 = S2.radius;
      double disc = dist * dist - R2 * R2 + R1 * R1;
      disc *= disc;
      disc = 4 * dist * dist * R1 * R1 - disc;
      if (disc < 0) {
        continue;
      }
      double x = (dist * dist - R2 *R2 + R1 * R1) / (2.0 * dist);
      P=new WB_Plane(WB_Point.addMul(S1.center, x, d), d);
      HE_VertexIterator vItr=S1.mesh.vItr();
      HE_Vertex v;
      while (vItr.hasNext()) {
        v=vItr.next();
        if (WB_GeometryOp.classifyPointToPlane3D(P, v)==WB_Classification.FRONT) {
          v.set(WB_GeometryOp.projectOnPlane(v.getPosition(), P));
        }
      }
      vItr=S2.mesh.vItr();
      while (vItr.hasNext()) {
        v=vItr.next();
        if (WB_GeometryOp.classifyPointToPlane3D(P, v)==WB_Classification.BACK) {
          v.set(WB_GeometryOp.projectOnPlane(v.getPosition(), P));
        }
      }
    }
  }
  /*for (int i=0; i<num; i++) {
    spheres.get(i).mesh.smooth();
  }*/
}


class Sphere {
  HE_Mesh mesh;
  WB_Point center;
  double radius;

  Sphere(WB_Coord center, double radius) {
    mesh=new HE_Mesh(new HEC_Geodesic().setC(0).setRadius(radius).setCenter(center));
    this.center=new WB_Point(center);
    this.radius=radius;
  }

  void resetMesh() {
    mesh=new HE_Mesh(new HEC_Geodesic().setC(0).setRadius(radius).setCenter(center));
  }
}
