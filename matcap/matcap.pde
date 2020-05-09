PShader matcap;
float range;
PShape shape;
public void setup() {
  size(600, 600, P3D);
  smooth(8);
  matcap=loadShader("MatCapFrag.glsl", "MatCapVert.glsl");
  range=0.98;
  matcap.set("range", range);
  matcap.set("matcap", loadImage("500.png"));
  shape=createShape();
  shape.beginShape(TRIANGLES);
  for (int i=-100; i<100; i++) {
    for (int j=-100; j<100; j++) {
      shape.vertex(i*2, j*2, bump(i, j));
      shape.vertex((i+1)*2, j*2, bump(i+1, j));
      shape.vertex((i+1)*2, (j+1)*2, bump(i+1, j+1));
      shape.vertex(i*2, j*2, bump(i, j));
      shape.vertex((i+1)*2, (j+1)*2, bump(i+1, j+1));
      shape.vertex(i*2, (j+1)*2, bump(i, j+1));
    }
  }
  shape.endShape();
  shape.disableStyle();
}

void draw() {
  background(25);
  translate(width / 2, height / 2);
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  scale(1.0);
  noLights();
  shader(matcap);
  noStroke();
  shape(shape);
}

float bump(int i, int j) {
  return 40*cos(radians(0.1*i*j));
}
