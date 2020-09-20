class Halfedge {
  Halfedge pair;
  Halfedge next;
  Halfedge prev;
  Vertex v;
  Face f;
  Edge e;
  int index;
  PVector UV;

  Halfedge(int i) {
    index=i;
    UV=new PVector();
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

  float distance(Plane P) {
    float signedDistance = P.normal.dot(new PVector(x-P.origin.x, y- P.origin.y, z-P.origin.z));
    return abs(signedDistance);
  }

  int sideOfPlane(Plane P) {
    float signedDistance = P.normal.dot(new PVector(x-P.origin.x, y- P.origin.y, z-P.origin.z));
    return (signedDistance>EPS)?1:(signedDistance<-EPS)?-1:0;
  }
}

class Face {
  Halfedge he; 
  int index;
  color col;
  int textureId;
  Face(int i, color col) {
    index=i;
    this.col=col;
    textureId=0;
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

class Edge {
  Halfedge he;
  int index;
  Edge(int i) {
    index=i;
  }
}

class Mesh {
  ArrayList<Halfedge> halfedges;
  ArrayList<Vertex> vertices;
  ArrayList<Face> faces;
  ArrayList<Edge> edges;



  Mesh() {
    initialize();
  }

  void initialize() {
    halfedges=new ArrayList<Halfedge>(); 
    vertices=new ArrayList<Vertex>();
    faces=new ArrayList<Face>();
    edges=new ArrayList<Edge>();
  }

  void create(MeshData data) {
    createRaw(data.vertexArray, data.faceArray, data.halfedgePairArray, data.faceColor);
    if(data.faceTextureIds!=null)setFaceTextureIds(data.faceTextureIds);
   if(data.UVs!=null)setUVs(data.UVs);
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
  }



  Mesh copy() {
    Mesh copy=new Mesh();
    copy.createRaw(copyVertexArray(), copyFaceArray(), copyHalfedgePairArray(), copyFaceColor());
    copy.setFaceTextureIds(copyFaceTextureIds());
    copy.setUVs(copyUVs());
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

  int[] copyFaceTextureIds() {
    int[] copy =new int[faces.size()];
    int index=0;
    for (Face f : faces) {
      copy[index]=f.textureId;
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


  float[][] copyUVs() {
    int[] oldtonew =new int[halfedges.size()];
    int[] newtoold =new int[halfedges.size()];
    float[][] copy =new float[halfedges.size()][2];
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
    PVector UV;
    for (int i=0; i<halfedges.size(); i++) {
      UV=halfedges.get(newtoold[i]).UV;
        copy[i]=new float[]{UV.x, UV.y};
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

  void draw(PImage... textures) {
    Halfedge he;
    for (Face f : faces) {
 
      beginShape();
       texture(textures[f.textureId]);
      he=f.he;
      do {

        vertex(he.v.x, he.v.y, he.v.z, he.UV.x, he.UV.y);
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

  void triangulate() {
    int numberOfTriangles=0;
    int[][] faces=copyFaceArray();
    color[] colors=copyFaceColor();
    for (int[] face : faces) {
      numberOfTriangles+=face.length-2;
    }
    int[][] triFaces=new int[numberOfTriangles][];
    color[] triColors=new color[numberOfTriangles];
    int index=0;
    int fc=0;
    for (int[] face : faces) {
      for (int i=1; i<face.length-1; i++) {
        triFaces[index]=new int[]{face[0], face[i], face[i+1]};
        triColors[index]=colors[fc];
        index++;
      }
      fc++;
    }
    create(MeshDataFactory.create(copyVertexArray(), triFaces, triColors));
  }

  void save(String path) {
    Mesh copy=copy();
    copy.triangulate();
    PrintWriter out=createWriter(path);
    for (Vertex v : copy.vertices) {
      out.println("v "+v.x+" "+v.y+" "+v.z);
    }
    Halfedge he;
    for (Face f : copy.faces) {
      out.print("f");
      he=f.he;
      do {
        out.print(" "+(he.v.index+1));
        he=he.next;
      } while (he!=f.he);
      out.println();
    }
    out.flush();
  }

  float[] getExtents() {
    float[] extents=new float[]{1000000, 1000000, 1000000, -1000000, -1000000, -1000000};
    for (Vertex v : vertices) {
      extents[0]=min(v.x, extents[0]);
      extents[1]=min(v.y, extents[1]);
      extents[2]=min(v.z, extents[2]);
      extents[3]=max(v.x, extents[3]);
      extents[4]=max(v.y, extents[4]);
      extents[5]=max(v.z, extents[5]);
    }
    return extents;
  }


  void setFaceTextureIds(int[] textureIds) {
    int id=0;
    for (Face f : faces) {
      f.textureId=textureIds[id++];
    }
  }

  void setUVs(float[][] UVs) {
    int id=0;
    for (Halfedge he : halfedges) {
      he.UV=new PVector(UVs[id][0], UVs[id][1]);
      id++;
    }
  }
}

PShape getPShape(Mesh mesh) {
  if (mesh.isValid()) {
    PShape shape=createShape(GROUP);
    Halfedge he;
    for (Face f : mesh.faces) {
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
    return shape;
  } else {
    return createShape();
  }
}
