import wblut.math.*;
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.nurbs.*;
import wblut.processing.*;
import java.util.*;

WB_Render3D render;

void setup(){
  fullScreen(P3D);
  smooth(8);
  render=new WB_Render3D(this);
}

void draw(){
 background(15);
 translate(width/2, height/2);
 rotateY(map(mouseX,0,width,-PI,PI));
 rotateX(map(mouseY,0,height,PI,-PI));
 scale(1,-1,1);
 stroke(240);
  
}
