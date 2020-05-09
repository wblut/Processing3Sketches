import wblut.math.*;
import wblut.processing.*;
import wblut.hemesh.*;
import wblut.geom.*;
import java.util.List;

HE_Mesh container;
HE_Mesh[] meshes;
WB_Render3D render;
WB_GeometryFactory3D factory;
List<HE_Path> paths;
HET_MeshNetwork meshNetwork;
WB_Network network;
int currentSource;
WB_Vector[] rotAxis;
float ax, ay;
void setup() {
  fullScreen(P3D);
  smooth(8);
  render= new WB_Render3D(this);
  factory=WB_GeometryFactory3D.instance();
  create();
}

void create() {
  meshes=new HE_Mesh[10];
  rotAxis=new WB_Vector[10];
  for (int i=0; i<10; i++) {
    container=new HE_Mesh(new HEC_Geodesic().setRadius(40+40*i).setB(3).setC(0)).modify(new HEM_Dual());
    rotAxis[i]=container.getVertexWithIndex(8*i).getVertexNormal();
    meshNetwork=new HET_MeshNetwork(container);
    network=meshNetwork.getNetwork(8*i,8);
    HEC_FromNetwork creator=new HEC_FromNetwork();
    creator.setNetwork(network);
    creator.setConnectionRadius(1+0.3*i);// strut radius
    creator.setConnectionFacets(4);// number of faces in the struts, min 3, max whatever blows up the CPU
    creator.setTaper(true);// allow struts to have different radii at each end?
    creator.setMaximumConnectionOffset(2+0.6*i);
    creator.setUseNodeValues(false);
    meshes[i]=new HE_Mesh(creator);
  }
}

void draw() {
  background(20);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  translate(width/2, height/2, 0);
  ay=mouseX*1.0f/width*TWO_PI;
  rotateY(ay);
  ax=mouseY*1.0f/height*TWO_PI;
  rotateX(ax);
  fill(255);
  noStroke();
  for (int i=0; i<10; i++) {
    render.drawFaces(meshes[i]);
  }
  stroke(255, 50);
  render.drawEdges(container);   
  stroke(255, 0, 0);
  render.drawNetwork(meshNetwork);
  update();
}


void update(){
   for (int i=0; i<9; i++) {
    meshes[i].rotateAboutAxisSelf((9-i)*0.001,WB_Point.ZERO(),rotAxis[i]);
  }
  
  
}
