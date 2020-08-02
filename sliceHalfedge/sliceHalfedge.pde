HalfedgeMesh mesh;

void setup() {
  size(800, 800, P3D);
  smooth(16);
  float[][] vertices=new float[][]{{-100, -100, -100}, {100, -100, -100}, {100, 100, -100}, {-100, 100, -100}, {-100, -100, 100}, {100, -100, 100}, {100, 100, 100}, {-100, 100, 100}};
  int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};

  mesh=new HalfedgeMesh();
  mesh.create(vertices, faces);
}

void draw() {
  background(250);
  translate(width/2, height/2);
  lights();
  rotateY(map(mouseX, 0, width, -PI, PI));
  rotateX(map(mouseY, 0, height, PI, -PI));
  mesh.draw();
}

void mousePressed() {
  mesh.split(new Point(random(-50, 50), random(-50, 50), random(-50, 50)), new Vector(random(-1, 1), random(-1, 1), random(-1, 1)));
}

class Halfedge {
  Halfedge pair;
  Halfedge next;
  Halfedge prev;
  Vertex v;
  Face f;
  Edge e;

  Halfedge() {
  }

  Halfedge nextInVertex() {
    return pair.next;
  }

  Halfedge prevInVertex() {
    return prev.pair;
  }
}

class Vertex {
  float x, y, z;
  Halfedge he;  
  int index;
  Vertex(float x, float y, float z, int i) {
    this.x=x;
    this.y=y;
    this.z=z;
    this.index=i;
  }
}


class Edge {
  Halfedge he;
  Edge() {
  }
}

class Face {
  Halfedge he; 
  Face() {
  }
}

class HalfedgeMesh {
  ArrayList<Halfedge> halfedges;
  ArrayList<Vertex> vertices;
  ArrayList<Face> faces;
  ArrayList<Edge> edges;

  HalfedgeMesh() {
    initialize();
  }

  void initialize() {
    halfedges=new ArrayList<Halfedge>(); 
    vertices=new ArrayList<Vertex>();
    faces=new ArrayList<Face>();
    edges=new ArrayList<Edge>();
  }

  void create(float[][] vertexArray, int[][] faceArray) {
    initialize();
    for (float[] vertex : vertexArray) {
      createVertex(vertex);
    }
    for (int[] face : faceArray) {
      createFace(face);
    }
    createEdges();
  }

  void createVertex(float... vertex) {
    vertices.add(new Vertex(vertex[0], vertex[1], vertex[2], vertices.size()));
  }

  void createFace(int[] face) {
    Face f=new Face();
    faces.add(f);
    Vertex v;
    Halfedge he;
    ArrayList<Halfedge> faceHalfedges=new ArrayList<Halfedge>(); 
    for (int i=0; i<face.length; i++) {
      v=vertices.get(face[i]);
      he=new Halfedge();
      faceHalfedges.add(he);
      connectVertex(v, he);
      connectFace(f, he);
    }
    for (int i=0, j=faceHalfedges.size()-1; i<faceHalfedges.size(); j=i, i++) {
      connectHalfedges(faceHalfedges.get(j), faceHalfedges.get(i));
    }
    halfedges.addAll(faceHalfedges);
  }

  void createEdges() {
    for (Halfedge he : halfedges) {
      if (he.pair==null) {
        for (Halfedge trial : halfedges) {
          if (trial!= he && trial.pair==null) {
            if (he.next.v==trial.v && he.v==trial.next.v) {
              pairHalfedges(he, trial);
              createEdge(he);
            }
          }
        }
      }
    }
  }

  void pairHalfedges(Halfedge he1, Halfedge he2) {
    he1.pair=he2;
    he2.pair=he1;
  }
  
  void createEdge(Halfedge he) {
    Edge e=new Edge();
    connectEdge(e, he);
    edges.add(e);
  }

  void connectHalfedges(Halfedge he1, Halfedge he2) {
    he1.next=he2;
    he2.prev=he1;
  }

  void connectVertex(Vertex v, Halfedge he) {
    if (v.he==null) v.he=he; 
    he.v=v;
  }

  void connectFace(Face f, Halfedge he) {
    if (f.he==null) f.he=he; 
    he.f=f;
  }

  void connectEdge(Edge e, Halfedge he) {
    if (e.he==null) e.he=he; 
    he.e=e;
    he.pair.e=e;
  }
  
  void splitEdge(Edge e, float f) {
    Halfedge he=e.he;
    Halfedge hep=he.pair;
    Halfedge hen=he.next;
    Halfedge hepn=hep.next;
    Vertex v=he.v;
    Vertex vp=hep.v;
    createVertex((1.0-f)*v.x+f*vp.x, (1.0-f)*v.y+f*vp.y, (1.0-f)*v.z+f*vp.z);
    Vertex splitv=vertices.get(vertices.size()-1);
    Halfedge heNew=new Halfedge();
    connectVertex(splitv, heNew);
    connectFace(he.f, heNew);
    Halfedge hepNew=new Halfedge();
    connectVertex(splitv, hepNew);
    connectFace(hep.f, hepNew);
    connectHalfedges(he, heNew);
    connectHalfedges(heNew, hen);
    connectHalfedges(hep, hepNew);
    connectHalfedges(hepNew, hepn);
    pairHalfedges(he, hepNew);
    connectEdge(e, he);
    pairHalfedges(hep, heNew);
    createEdge(hep);
  }

  class EdgeIntersection {
    Edge e;
    Vertex v;

    EdgeIntersection(Edge e, Vertex v) {
      this.e=e;
      this.v=v;
    }
  }

  void split(Point origin, Vector normal) {
    ArrayList<EdgeIntersection> intersections=new ArrayList<EdgeIntersection>();
    int es=edges.size();
    for (int i=0; i<es; i++) {
      splitEdge(edges.get(i), origin, normal, intersections);
    }

    int fs=faces.size();
    for (int i=0; i<fs; i++) {
      splitFace(faces.get(i), intersections);
    }
  }

  void splitEdge(Edge e, Point origin, Vector normal, ArrayList<EdgeIntersection> intersections) {
    Halfedge he=e.he;
    Halfedge hep=he.pair;
    Vertex v=he.v;
    Vertex vp=hep.v;
    Vector u=new Vector(vp.x-v.x, vp.y-v.y, vp.z-v.z);
    Vector w=new Vector(v.x-origin.x, v.y-origin.y, v.z-origin.z);
    float D=normal.dot(u);
    float N=-normal.dot(w);
    if (abs(D)<0.0001) {
      return;
    }
    float f=N/D;
    if (f<-0.0001||f>1.0001) {
      return;
    } else if (f<0.0001) {
      intersections.add(new EdgeIntersection(e, v));
    } else if (f>0.9999) {
      intersections.add(new EdgeIntersection(e, vp));
    } else {
      splitEdge(e, f);
      Vertex nv=vertices.get(vertices.size()-1);
      intersections.add(new EdgeIntersection(e, nv));
    }
  }

  void splitFace(Face f, ArrayList<EdgeIntersection> intersections) {
    Vertex vi=null;
    Vertex vj=null;
    for (EdgeIntersection ei : intersections) {
      if (ei.e.he.f==f || ei.e.he.pair.f==f) {
        if (vi==null) {
          vi=ei.v;
        } else 
        if (vi!=ei.v) {
          vj=ei.v;
          break;
        }
      }
    }
    if (vi!=null&&vj!=null) splitFace(f, vi.index, vj.index);
  }

  void splitFace(Face f, int i, int j) {
    Vertex vi=vertices.get(i);
    Halfedge hei=f.he;
    while (hei.v!=vi) {
      hei=hei.next; 
      if (hei==f.he) return;
    }

    Vertex vj=vertices.get(j);
    Halfedge hej=f.he;
    while (hej.v!=vj) {
      hej=hej.next; 
      if (hej==f.he) return;
    }

    if (hei.next==hej || hej.next==hei) return;

    Halfedge heip=hei.prev;
    Halfedge hejp=hej.prev;
    Halfedge heNew=new Halfedge();
    Halfedge hepNew=new Halfedge();
    connectVertex(vi, hepNew);
    connectVertex(vj, heNew);
    pairHalfedges(heNew, hepNew);
    createEdge(heNew);
    halfedges.add(heNew);
    halfedges.add(hepNew);
    connectHalfedges(heip, hepNew);
    connectHalfedges(hepNew, hej);
    connectHalfedges(hejp, heNew);
    connectHalfedges(heNew, hei);
    heNew.f=f;
    Halfedge he=hej;
    Face nf=new Face();
    faces.add(nf);
    do {
      connectFace(nf, he); 
      he=he.next;
    } while (he!=hej);
    f.he=hei;
  }

  void draw() {
    Halfedge he;
    for (Face f : faces) {
      beginShape();
      he=f.he;
      do {
        vertex(he.v.x, he.v.y, he.v.z);
        he=he.next;
      } while (he!=f.he);
      endShape(CLOSE);
    }
    
    for (Vertex v : vertices) {
      pushMatrix();
      translate(v.x, v.y, v.z);
      box(2);
      popMatrix();
    }
    
  }
}


class Point {
  float x, y, z; 
  Point(float x, float y, float z) {
    this.x=x;
    this.y=y;
    this.z=z;
  }
}

class Vector {
  float x, y, z; 
  Vector(float x, float y, float z) {
    this.x=x;
    this.y=y;
    this.z=z;
  }

  float dot(Vector v) {
    return x*v.x+y*v.y+z*v.z;
  }
}
