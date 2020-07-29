
float EPS=0.0001;
float OMEPS=0.9999;
float OPEPS=1.0001;

class Halfedge {
  Halfedge pair;
  Halfedge next;
  Halfedge prev;
  Vertex v;
  Face f;
  Edge e;
  int index;

  Halfedge(int i) {
    index=i;
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

  int sideOfPlane(PVector origin, PVector normal) {
    float signedDistance = normal.dot(new PVector(x-origin.x, y- origin.y, z-origin.z));
    return (signedDistance>EPS)?1:(signedDistance<-EPS)?-1:0;
  }
}

class Edge {
  Halfedge he;
  int index;
  Edge(int i) {
    index=i;
  }
}

class Face {
  Halfedge he; 
  int index;
  Face(int i) {
    index=i;
  }

  int order() {
    Halfedge lhe=he;
    int order=0;
    do {
      order++;
      lhe=lhe.next;
    } while (lhe!=he);
    return order;
  }

  int sideOfPlane(PVector origin, PVector normal) {
    Halfedge lhe=he;
    int sideOfVertex;
    int plus=0;
    int minus=0;
    do {
      sideOfVertex = lhe.v.sideOfPlane(origin, normal);
      if (sideOfVertex==1) { 
        plus++;
      } else  if (sideOfVertex==-1) { 
        minus++;
      }
      lhe=lhe.next;
    } while (lhe!=he);
    if (plus>0 && minus==0) {
      return 1;
    } else if (plus==0 && minus>0) {
      return -1;
    } else {
      return 0;
    }
  }
}


class SliceBox {
  ArrayList<Halfedge> halfedges;
  ArrayList<Vertex> vertices;
  ArrayList<Face> faces;
  ArrayList<Edge> edges;

  PShape shape;

  SliceBox() {
    initialize();
  }

  void initialize() {
    halfedges=new ArrayList<Halfedge>(); 
    vertices=new ArrayList<Vertex>();
    faces=new ArrayList<Face>();
    edges=new ArrayList<Edge>();
  }

  void createBoxWithCenterAndSize(float x, float y, float z, float width, float height, float depth) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+vertices[i][0]*width;
      scaledVertices[i][1]=y+vertices[i][1]*height;
      scaledVertices[i][2]=z+vertices[i][2]*depth;
    }
    createRaw(scaledVertices, faces, halfedgePairs);
  }

  void createBoxWithCornerAndSize(float x, float y, float z, float width, float height, float depth) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+(0.5+vertices[i][0])*width;
      scaledVertices[i][1]=y+(0.5+vertices[i][1])*height;
      scaledVertices[i][2]=z+(0.5+vertices[i][2])*depth;
    }
    createRaw(scaledVertices, faces, halfedgePairs);
  }

  void createRaw(float[][] vertexArray, int[][] faceArray, int[] halfedgePairArray) {
    initialize();
    for (float[] vertex : vertexArray) {
      createVertex(vertex);
    }
    for (int[] face : faceArray) {
      createFace(face);
    }
    createEdges(halfedgePairArray);
    toPShape();
  }

  void toPShape() {
    if (isValid()) {
      shape=createShape(GROUP);
      Halfedge he;
      for (Face f : faces) {
        PShape facet=createShape();
        facet.beginShape();
        he=f.he;
        do {
          facet.vertex(he.v.x, he.v.y, he.v.z);
          he=he.next;
        } while (he!=f.he);
        facet.endShape(CLOSE);
        shape.addChild(facet);
      }
      shape.disableStyle();
    }
  }

  SliceBox copy() {
    SliceBox copy=new SliceBox();
    copy.createRaw(copyVertexArray(), copyFaceArray(), copyHalfedgePairArray());
    return copy;
  }

  float[][] copyVertexArray() {
    float[][] copy =new float[vertices.size()][3];
    int index=0;  
    for (Vertex v : vertices) {
      copy[index][0]=v.x;
      copy[index][1]=v.y;
      copy[index][2]=v.z;
      index++;
    }
    return copy;
  }

  int[][] copyFaceArray() {
    int[][] copy =new int[faces.size()][];
    int index=0;
    int order, hei;
    Halfedge he;
    for (Face f : faces) {
      order=f.order();
      copy[index]=new int[order];
      hei=0;
      he=f.he;
      do {
        copy[index][hei++]=he.v.index;
        he=he.next;
      } while (he!=f.he);
      index++;
    }
    return copy;
  }

  int[] copyHalfedgePairArray() {
    int[] oldtonew =new int[halfedges.size()];
    int[] newtoold =new int[halfedges.size()];
    int[] copy =new int[halfedges.size()];
    int index=0;
    Halfedge he;
    for (Face f : faces) {
      he=f.he;
      do {
        oldtonew[he.index]=index;
        newtoold[index]=he.index;
        index++;
        he=he.next;
      } while (he!=f.he);
    }

    for (int i=0; i<halfedges.size(); i++) {
      copy[i]=oldtonew[halfedges.get(newtoold[i]).pair.index];
    }

    return copy;
  }

  void createVertex(float... vertex) {
    vertices.add(new Vertex(vertex[0], vertex[1], vertex[2], vertices.size()));
  }

  void createFace(int[] face) {
    Face f=new Face(faces.size());
    faces.add(f);
    Vertex v;
    Halfedge he;
    ArrayList<Halfedge> faceHalfedges=new ArrayList<Halfedge>(); 
    for (int i=0; i<face.length; i++) {
      v=vertices.get(face[i]);
      he=new Halfedge(halfedges.size());
      halfedges.add(he);
      faceHalfedges.add(he);
      connectVertex(v, he);
      connectFace(f, he);
    }
    for (int i=0, j=faceHalfedges.size()-1; i<faceHalfedges.size(); j=i, i++) {
      connectHalfedges(faceHalfedges.get(j), faceHalfedges.get(i));
    }
  }

  void createEdges(int[] halfedgePairArray) {
    for (Halfedge he : halfedges) {
      int pairIndex=halfedgePairArray[he.index];
      if (he.pair==null) {
        pairHalfedges(he, halfedges.get(pairIndex));
        createEdge(he);
      } else {
        assert (he.pair.index==pairIndex);
      }
    }
  }

  void pairHalfedges(Halfedge he1, Halfedge he2) {
    he1.pair=he2;
    he2.pair=he1;
  }

  void createEdge(Halfedge he) {
    Edge e=new Edge(edges.size());
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

  void slice(PVector origin, PVector normal, float offset) {
    ArrayList<EdgeIntersection> intersections=new ArrayList<EdgeIntersection>();
    origin=new PVector(origin.x-offset*normal.x, origin.y-offset*normal.y, origin.z-offset*normal.z);
    int es=edges.size();
    for (int i=0; i<es; i++) {
      sliceEdge(edges.get(i), origin, normal, intersections);
    }

    int fs=faces.size();
    for (int i=0; i<fs; i++) {
      sliceFace(faces.get(i), intersections);
    }

    deleteFrontFaces(origin, normal);
    capSlice();
    toPShape();
  }

  void sliceEdge(Edge e, PVector origin, PVector normal, ArrayList<EdgeIntersection> intersections) {
    Halfedge he=e.he;
    Halfedge hep=he.pair;
    Vertex v=he.v;
    Vertex vp=hep.v;
    PVector u=new PVector(vp.x-v.x, vp.y-v.y, vp.z-v.z);
    PVector w=new PVector(v.x-origin.x, v.y-origin.y, v.z-origin.z);
    float D=normal.dot(u);
    float N=-normal.dot(w);
    if (abs(D)<0.0001) {
      return;
    }
    float f=N/D;
    if (f<-EPS||f>OPEPS) {
      return;
    } else if (f<EPS) {
      intersections.add(new EdgeIntersection(e, v));
    } else if (f>OMEPS) {
      intersections.add(new EdgeIntersection(e, vp));
    } else {
      splitEdge(e, f);
      Vertex nv=vertices.get(vertices.size()-1);
      intersections.add(new EdgeIntersection(e, nv));
    }
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
    Halfedge heNew=new Halfedge(halfedges.size());
    halfedges.add(heNew);
    connectVertex(splitv, heNew);
    connectFace(he.f, heNew);
    Halfedge hepNew=new Halfedge(halfedges.size());
    halfedges.add(hepNew);
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

  void sliceFace(Face f, ArrayList<EdgeIntersection> intersections) {
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
    Halfedge heNew=new Halfedge(halfedges.size());
    Halfedge hepNew=new Halfedge(halfedges.size());
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
    Face nf=new Face(faces.size());
    faces.add(nf);
    do {
      connectFace(nf, he); 
      he=he.next;
    } while (he!=hej);
    f.he=hei;
  }

  void deleteFace(Face f) {
    Halfedge he=f.he;
    do {
      if (he.v.he==he) he.v.he=null;
      if (he.pair!=null) {
        he.pair.pair=null;
        he.pair.e=null;
      }
      halfedges.remove(he);
      edges.remove(he.e);
      he=he.next;
    } while (he!=f.he);  
    faces.remove(f);
    reconnectVertices();
    indexHalfedges();
    indexFaces();
    indexEdges();
    ArrayList<Vertex> checklist=new ArrayList<Vertex>();
    checklist.addAll(vertices);
    for (Vertex v : checklist) {
      if (v.he==null) vertices.remove(v);
    }
    indexVertices();
  }

  void deleteFrontFaces(PVector origin, PVector normal) {
    ArrayList<Face> checklist=new ArrayList<Face>();
    checklist.addAll(faces);
    for (Face f : checklist) {
      if (f.sideOfPlane(origin, normal)==1) {
        deleteFace(f);
      }
    }
  }

  void capSlice() {
    Face cap=new Face(faces.size());
    Halfedge caphe, trial;
    ArrayList<Halfedge> capHalfedges=new ArrayList<Halfedge>();
    for (Halfedge he : halfedges) {
      if (he.pair==null) {
        caphe=new Halfedge(halfedges.size()+capHalfedges.size()); 
        capHalfedges.add(caphe);
        pairHalfedges(he, caphe);
        createEdge(he);
        connectVertex(he.next.v, caphe);
        connectFace(cap, caphe);
      }
    }
    halfedges.addAll(capHalfedges);
    if (capHalfedges.size()>0) faces.add(cap);
    for (int i=0; i<capHalfedges.size(); i++) {
      caphe=capHalfedges.get(i);
      if (caphe.next==null) {
        for (int j=0; j<capHalfedges.size(); j++) {
          trial=capHalfedges.get(j);
          if (i!=j && trial.v==caphe.pair.v) {
            connectHalfedges(caphe, trial);
            break;
          }
        }
      }
    }
  }

  void drawShape() {
    shape(shape);
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
  }

  void indexVertices() {
    int index=0;
    for (Vertex v : vertices) {
      v.index=index++;
    }
  }

  void indexHalfedges() {
    int index=0;
    for (Halfedge he : halfedges) {
      he.index=index++;
    }
  }

  void indexEdges() {
    int index=0;
    for (Edge e : edges) {
      e.index=index++;
    }
  }

  void indexFaces() {
    int index=0;
    for (Face f : faces) {
      f.index=index++;
    }
  }

  void reconnectVertices() {
    int index=0;
    for (Halfedge he : halfedges) {
      if (he.v.he==null) he.v.he=he;
    }
  }

  boolean isValid() {
    for (Halfedge he : halfedges) {
      if (he.v==null) return false; 
      if (he.pair==null) return false;
      if (he.pair.pair==null) return false;
      if (he.pair.pair!=he) return false;
      if (he.f==null) return false;
      if (he.next==null) return false;
      if (he.next.prev==null) return false;
      if (he.next.prev!=he) return false;
      if (he.prev==null) return false;
      if (he.prev.next==null) return false;
      if (he.prev.next!=he) return false;
    }
    return true; //maybe
  }
}
