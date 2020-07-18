import processing.svg.*;
Spiral S;
float RADIUS;
int NUMPOINTSPERTURN;
int NUMTURNS;
PImage image;
float imageScale;
void setup() {
  size(1000, 1000, P3D);
  smooth(16);
  image=loadImage("portrait.jpg");//CC0 https://www.piqsels.com/
  
  NUMTURNS=40;
  NUMPOINTSPERTURN=1000;
  RADIUS=400.0;
  imageScale=min(0.5*image.width/(RADIUS+4), 0.5*image.height/(RADIUS+4));
}

void draw() {
  background(255);
  drawSpiral("spiral001", color(0), 0, 0);
  drawSpiral("spiral002", color(0), 0, 1);
  drawSpiral("spiral003", color(0), 0, -1);
  drawSpiral("spiral004", color(0), 0, 2);
  drawSpiral("spiral005", color(0), 0, -2);
  noLoop();
}

void drawSpiral(String name, color col, float angle, float displacement) {
  pushMatrix();
  beginRecord(SVG, "/SVG/"+name+".svg");
  translate(width/2, height/2);
  S=new Spiral(RADIUS, NUMTURNS*NUMPOINTSPERTURN, NUMTURNS, angle, displacement);
  noFill();
  stroke(col);
  S.draw();
  rect(-width/2, -height/2, width, height);
  endRecord();
  popMatrix();
}


class Spiral {
  float[] points;
  Spiral(float r, int num, float s, float angle, float displacement) {
    float dr=r/num;
    points=new float[2*num];
    int id=0;
    float radius;
    float displacementFactor=0.0;
    float hysteresis=0.5;
    for (int i=0; i<num; i++) {
      radius=i*dr;
      float x=radius* cos(i*s*TWO_PI/num+angle);
      float y=radius* sin(i*s*TWO_PI/num+angle);
       displacementFactor=hysteresis*displacementFactor+(1.0-hysteresis)*map(brightness(image.get(image.width/2+(int)(imageScale*x),image.height/2+(int)(imageScale*y))),0,255,1.0,0.0);
      points[id++]=x*((radius==0)?0.0:(radius+displacement*displacementFactor)/radius);
      points[id++]=y*((radius==0)?0.0:(radius+displacement*displacementFactor)/radius);
    }
  }

  void draw() {
    beginShape();
    for (int i=0; i<points.length; i+=2) {
      vertex(points[i], points[i+1]);
    }
    endShape(OPEN);
  }
}
