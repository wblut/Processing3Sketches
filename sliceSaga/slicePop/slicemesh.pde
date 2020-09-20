class SliceMesh extends Mesh {
  SliceMesh() {
    super();
  }

  SliceMesh copy() {
    SliceMesh copy=new SliceMesh();
    copy.createRaw(copyVertexArray(), copyFaceArray(), copyHalfedgePairArray(), copyFaceColor());
     copy.setFaceTextureIds(copyFaceTextureIds());
    copy.setUVs(copyUVs());

    return copy;
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
    capSlice(col,offsetP);

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
    if (abs(D)<EPS) {
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
    heNew.UV=PVector.lerp(he.UV,hen.UV,f);
    connectHalfedges(hep, hepNew);
    connectHalfedges(hepNew, hepn);
    hepNew.UV=PVector.lerp(hep.UV,hepn.UV,1.0-f);
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
    heNew.UV=hej.UV.copy();
    hepNew.UV=hei.UV.copy();
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
    nf.textureId=f.textureId;
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

  void capSlice(color col, Plane P) {
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
        PVector local=P.local(caphe.v.x,caphe.v.y,caphe.v.z);
        caphe.UV=new PVector((local.x+400.0)/800.0,(local.y+400.0)/800.0);
        connectFace(cap, caphe);
        cap.textureId=7+currentSlice;
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

}
