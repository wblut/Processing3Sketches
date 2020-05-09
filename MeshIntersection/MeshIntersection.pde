import wblut.math.*;
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.nurbs.*;
import wblut.processing.*;
import java.util.*;
import wblut.hemesh.HE_MeshOp.HE_FaceFaceIntersection;
WB_Render3D render;
HE_Mesh mesh1;
HE_Mesh mesh2;
List<HE_FaceFaceIntersection> intersections;

void setup() {
  fullScreen(P3D);
  smooth(8);
  render=new WB_Render3D(this);
  mesh1=new HEC_Torus(100, 240, 16, 16).create();
  mesh2=new HEC_Box(350, 350, 350, 10, 10, 10).setAxis(1, 1, 1).setCenter(100, 0, 0).create();
  mesh1.smooth();
  mesh2.smooth();
  intersections=HE_MeshOp.getIntersection(mesh1, mesh2);
}

void draw() {
  background(15);
  translate(width/2, height/2);
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  lights();
  strokeWeight(1.0);
  stroke(240, 120);
  render.drawEdges(mesh1);
  render.drawEdges(mesh2);
  strokeWeight(4.0);
  stroke(0, 0, 255);
  for (HE_FaceFaceIntersection intersection : intersections) {
    render.drawSegment(intersection.getSegment());
  }
  noStroke();
  fill(255, 0, 0);
  render.drawFaces(mesh1.getSelection("intersection"));
  render.drawFaces(mesh2.getSelection("intersection"));
}
