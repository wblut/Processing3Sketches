
float EPS=0.0001;
float OMEPS=0.9999;
float OPEPS=1.0001;

class Plane {
  PVector origin;
  PVector normal;
  PVector u, v;

  Plane(PVector origin, PVector normal) {
    this.origin=origin.copy();
    this.normal=normal.copy();
    this.normal.normalize();
    u=new PVector(0, 0, 1).cross(normal);
    if (sqrt(u.dot(u))<EPS) {
      u=new PVector(0, 1, 0).cross(normal);
    }
    u.normalize();
    v=normal.cross(u);
  }


  Plane offset(float d) {
    return new Plane(PVector.add(origin, PVector.mult(normal, d)), normal);
  }

  Plane flip() {
    return new Plane(origin, PVector.mult(normal, -1));
  }

  void draw(float side) {
    beginShape();
    vertex(origin.x-0.5*side*u.x-0.5*side*v.x, origin.y-0.5*side*u.y-0.5*side*v.y, origin.z-0.5*side*u.z-0.5*side*v.z);
    vertex(origin.x+0.5*side*u.x-0.5*side*v.x, origin.y+0.5*side*u.y-0.5*side*v.y, origin.z+0.5*side*u.z-+0.5*side*v.z);
    vertex(origin.x+0.5*side*u.x+0.5*side*v.x, origin.y+0.5*side*u.y+0.5*side*v.y, origin.z+0.5*side*u.z+0.5*side*v.z);
    vertex(origin.x-0.5*side*u.x+0.5*side*v.x, origin.y-0.5*side*u.y+0.5*side*v.y, origin.z-0.5*side*u.z+0.5*side*v.z);
    endShape();
  }
}

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

  int sideOfPlane(Plane P) {
    float signedDistance = P.normal.dot(new PVector(x-P.origin.x, y- P.origin.y, z-P.origin.z));
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
  color col;
  Face(int i, color col) {
    index=i;
    this.col=col;
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

  int sideOfPlane(Plane P) {
    Halfedge lhe=he;
    int sideOfVertex;
    int plus=0;
    int minus=0;
    do {
      sideOfVertex = lhe.v.sideOfPlane(P);
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

  void createBoxWithCenterAndSize(float x, float y, float z, float width, float height, float depth, color col) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+vertices[i][0]*width;
      scaledVertices[i][1]=y+vertices[i][1]*height;
      scaledVertices[i][2]=z+vertices[i][2]*depth;
    }
    createRaw(scaledVertices, faces, halfedgePairs, new color[]{col, col, col, col, col, col});
  }

  void createBoxWithCornerAndSize(float x, float y, float z, float width, float height, float depth, color[] col) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+(0.5+vertices[i][0])*width;
      scaledVertices[i][1]=y+(0.5+vertices[i][1])*height;
      scaledVertices[i][2]=z+(0.5+vertices[i][2])*depth;
    }
    createRaw(scaledVertices, faces, halfedgePairs, col);
  }

  void createRaw(float[][] vertexArray, int[][] faceArray, int[] halfedgePairArray, color[] col) {
    initialize();
    for (float[] vertex : vertexArray) {
      createVertex(vertex);
    }
    int i=0;
    for (int[] face : faceArray) {
      createFace(face, col[i++]);
    }
    createEdges(halfedgePairArray);
    toPShape();
  }


  void createOcathedronWithCenterAndSize(float x, float y, float z, float width, float height, float depth, color col) {
    float[][] vertices=new float[][]{{-0.5, 0, 0}, {0, 0.5, 0}, {0.5, 0, 0}, {0, -0.5, 0}, {0, 0, 0.5}, {0, 0, -0.5}};
    int[][] faces=new int[][]{{0, 1, 4}, {1, 2, 4}, {2, 3, 4}, {3, 0, 4}, {1, 0, 5}, {2, 1, 5}, {3, 2, 5}, {0, 3, 5}};
    int[] halfedgePairs=new int[]{12, 5, 10, 15, 8, 1, 18, 11, 4, 21, 2, 7, 0, 23, 16, 3, 14, 19, 6, 17, 22, 9, 20, 13};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+vertices[i][0]*width;
      scaledVertices[i][1]=y+vertices[i][1]*height;
      scaledVertices[i][2]=z+vertices[i][2]*depth;
    }
    createRaw(scaledVertices, faces, halfedgePairs, new color[]{col, col, col, col, col, col, col, col});
  }


  void createPrismWithCenterRadiusAndHeight(int N, float x, float y, float z, float radius, float height, color col) {
    createPrismWithCenterRadiusRangeAndHeight(N, x, y, z, radius, radius, height, col);
  }

  void createPrismWithCenterRadiusRangeAndHeight(int N, float x, float y, float z, float minRadius, float maxRadius, float height, color col) {
    float[][] vertices=new float[2*N][3];

    float radius;
    for (int i=0; i<N; i++) {
      radius=random(minRadius, maxRadius);
      vertices[i][0]=vertices[i+N][0]=cos(TWO_PI/N*i)*radius+x; 
      vertices[i][1]=vertices[i+N][1]=sin(TWO_PI/N*i)*radius+y;
      vertices[i][2]=-height/2+z;
      vertices[i+N][2]=height/2+z;
    }
    int[][] faces =new int[N+2][];
    color[] cols=new color[N+2];
    faces[0]=new int[N];
    faces[1]=new int[N];
    cols[0]=col;
    cols[1]=col;
    for (int i=0; i<N; i++) {
      faces[0][i]=N-1-i;
      faces[1][i]=N+i;
    }
    for (int i=0; i<N; i++) {
      faces[i+2]=new int[4];

      faces[i+2][0]=i;
      faces[i+2][1]=(i+1)%N;
      faces[i+2][2]=faces[i+2][1]+N;
      faces[i+2][3]=faces[i+2][0]+N;
      cols[i+2]=col;
    }

    create(vertices, faces, cols);
  }
  void create(float[][] vertexArray, int[][] faceArray, int[] col) {
    int numberOfEdges=0;
    for (int[] face : faceArray) {
      numberOfEdges+=face.length;
    }
    int[] halfedgePairArray =new int[numberOfEdges];
    int[][] edges=new int[numberOfEdges][2];
    int index=0;
    for (int[] face : faceArray) {
      for (int i=0; i<face.length; i++) {
        edges[index][0]=face[i];
        edges[index][1]=face[(i+1)%face.length];
        halfedgePairArray[index]=-1;
        index++;
      }
    }
    for (int i=0; i<edges.length; i++) {
      if (halfedgePairArray[i]==-1) {
        for (int j=i+1; j<edges.length; j++) {
          if (edges[i][0]==edges[j][1] && edges[i][1]==edges[j][0]) {
            halfedgePairArray[i]=j;
            halfedgePairArray[j]=i;
          }
        }
      }
    }
    createRaw(vertexArray, faceArray, halfedgePairArray, col);
  }

  void toPShape() {
    /*
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
     */
  }

  SliceBox copy() {
    SliceBox copy=new SliceBox();
    copy.createRaw(copyVertexArray(), copyFaceArray(), copyHalfedgePairArray(), copyFaceColor());
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

  color[] copyFaceColor() {
    color[] copy =new color[faces.size()];
    int index=0;

    for (Face f : faces) {

      copy[index]=f.col;

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

  void createFace(int[] face, color col) {
    Face f=new Face(faces.size(), col);
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

  void slice(Plane P, float offset, color col) {
    Plane offsetP=P.offset(offset);
    ArrayList<EdgeIntersection> intersections=new ArrayList<EdgeIntersection>();

    int es=edges.size();
    for (int i=0; i<es; i++) {
      sliceEdge(edges.get(i), offsetP, intersections);
    }

    int fs=faces.size();
    for (int i=0; i<fs; i++) {
      sliceFace(faces.get(i), intersections);
    }

    deleteFrontFaces(offsetP);
    capSlice(col);
    toPShape();
  }

  void sliceEdge(Edge e, Plane P, ArrayList<EdgeIntersection> intersections) {
    Halfedge he=e.he;
    Halfedge hep=he.pair;
    Vertex v=he.v;
    Vertex vp=hep.v;
    PVector u=new PVector(vp.x-v.x, vp.y-v.y, vp.z-v.z);
    PVector w=new PVector(v.x-P.origin.x, v.y-P.origin.y, v.z-P.origin.z);
    float D=P.normal.dot(u);
    float N=-P.normal.dot(w);
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
    Face nf=new Face(faces.size(), f.col);
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

  void deleteFrontFaces(Plane P) {
    ArrayList<Face> checklist=new ArrayList<Face>();
    checklist.addAll(faces);
    for (Face f : checklist) {
      if (f.sideOfPlane(P)==1) {
        deleteFace(f);
      }
    }
  }

  void capSlice(color col) {
    Face cap=new Face(faces.size(), col);
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
      fill(f.col);
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
