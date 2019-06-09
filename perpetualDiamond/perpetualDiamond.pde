void setup() {
  size(800, 800);
  smooth(8);
  frameRate(30);
}


void draw() {
  float backgroundAngle= frameCount*24; //2hz = 720°/s =  24°/frame
  background(120+80*sin(radians(backgroundAngle)));
  translate(width/2, height/2);

  float phaseShiftUL=-90;
  float phaseShiftUR=+90;
  float phaseShiftLL=-90;
  float phaseShiftLR=+90;

  //edges
  strokeWeight(3.0);

  float edgeAngleUL= frameCount*24+phaseShiftUL;
  stroke(80+120*sin(radians(edgeAngleUL)));
  line(-200, 0, 0, -200);

  float edgeAngleUR= frameCount*24+phaseShiftUR;
  stroke(80+120*sin(radians(edgeAngleUR)));
  line(200, 0, 0, -200);

  float edgeAngleLL= frameCount*24+phaseShiftLL;
  stroke(80+120*sin(radians(edgeAngleLL)));
  line(-200,0,0, 200);

  float edgeAngleLR= frameCount*24+phaseShiftLR;
  stroke(80+120*sin(radians(edgeAngleLR)));
  line(200, 0, 0, 200);

  //diamond
  noStroke();
  fill(120);
  beginShape();
  vertex(-200, 0);
  vertex(0, -200);
  vertex(200, 0);
  vertex(0, 200);
  endShape();
}
