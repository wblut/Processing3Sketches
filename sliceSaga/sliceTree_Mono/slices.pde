class SliceTree {
  ArrayList<Slice> roots;
  float bufferedF;

  SliceTree(SliceBox mesh) {
    roots=new ArrayList<Slice>();
    roots.add(new Slice(mesh));
  }

  SliceTree(ArrayList<SliceBox> meshes) {
    roots=new ArrayList<Slice>();
    for (SliceBox mesh : meshes) {
      roots.add(new Slice(mesh));
    }
  }

  SliceTree(SliceBox... meshes) {
    roots=new ArrayList<Slice>();
    for (SliceBox mesh : meshes) {
      roots.add(new Slice(mesh));
    }
  }

  void split(Transformation M, color col, color col2) {
    for (Slice root : roots) {
      root.split(M, col, col2);
    }
  }

  void setPhase(float f) {
    for (Slice root : roots) {
      root.setPhase(f);
    }
  }

  float[] getExtents() {
    float[] extents=new float[]{1000000, 1000000, 1000000, -1000000, -1000000, -1000000};
    for (Slice root : roots) {
      root.addExtents(extents);
    }
    return extents;
  }

  void draw() {

    for (Slice root : roots) {
      root.draw();
    }
  }


 void draw(color col, PGraphics pg) {

    for (Slice root : roots) {
      root.draw(col, pg);
    }
  }

  float minDistance(Plane P) {
    float minDistance=1000000;
    for (Slice root : roots) {
      minDistance=min(minDistance, root.minDistance(P));
    }
    return minDistance;
  }
}



class Slice {
  Slice parent;
  Slice child1, child2;
  Transformation parentToChild;
  SliceBox mesh;
  SliceBox invTMesh;
  SliceBox dynMesh;
  SliceBox drawMesh;
  int level;

  Slice(SliceBox mesh) {
    this.mesh = mesh.copy();
    invTMesh = mesh.copy();
    dynMesh = mesh.copy();
    parentToChild = null;
    parent = null;
    child1 = null;
    child2 = null;
    level = 0;
  }

  Slice(SliceBox mesh, Slice parent, Transformation parentToChild) {
    this.mesh = mesh.copy();
    dynMesh= mesh.copy();
    this.parentToChild = parentToChild;
    this.parent = parent;
    invTMesh = mesh.copy();
    Slice p = this;
    do {
      if ( p.parentToChild!=null) {
        Transform T = p.parentToChild.getInverseTransform(1.0);
        T.apply(invTMesh);
      }
      p = p.parent;
    } while (p != null);
    level=parent.level+1;
  }

  void split(Transformation M, color col, color col2) {
    if ((child1 == null) && (child2 == null)) {
      SliceBox split1=mesh.copy();
      SliceBox split2=mesh.copy();
      split1.slice(M.plane, 0.0, col);
      split2.slice(M.plane.flip(), 0.0, col2);
      if (split1.vertices.size() > 0 && split1.isValid()) {
        child1 = new Slice(split1, this, null);
      }
      if (split2.vertices.size() > 0 && split2.isValid()) {
        M.getTransform(1.0).apply(split2);
        child2 = new Slice(split2, this, M);
      }
    } else {
      if (child1 != null) {
        child1.split(M, col, col2);
      }
      if (child2 != null) {
        child2.split(M, col2, col);
      }
    }
  }


  float minDistance(Plane P) {
    float minDistance=1000000;
    if (((child1 == null) && (child2 == null))) {//||f<=level) {
      for (Vertex v : mesh.vertices) {
        minDistance=min(minDistance, v.distance(P));
        if(minDistance<5.0) return minDistance;
      }
    } else {
      if (child1 != null) {
         minDistance=min(minDistance, child1.minDistance(P));
      }
      if (child2 != null) {
         minDistance=min(minDistance,  child2.minDistance(P));
      }
    }
    return minDistance;
  }

  void setPhase(float f) {
    if (((child1 == null) && (child2 == null))) {//||f<=level) {
      drawMesh = getMesh(f);
    } else {
      drawMesh=null;
      if (child1 != null) {
        child1.setPhase(f);
      }
      if (child2 != null) {
        child2.setPhase(f);
      }
    }
  }

  void addExtents(float[] extents) {
    if (drawMesh!=null) {
      float[] fragmentExtents=drawMesh.getExtents();
      for (int i=0; i<3; i++) {
        extents[i]=min(extents[i], fragmentExtents[i]);
        extents[i+3]=max(extents[i+3], fragmentExtents[i+3]);
      }
    } else {
      if (child1 != null) {
        child1.addExtents(extents);
      }
      if (child2 != null) {
        child2.addExtents(extents);
      }
    }
  }


  void draw() {
    if (drawMesh!=null) {
      drawMesh.draw();
    } else {
      if (child1 != null) {
        child1.draw();
      }
      if (child2 != null) {
        child2.draw();
      }
    }
  }
  
  void draw(color col, PGraphics pg) {
    if (drawMesh!=null) {
      drawMesh.draw(col, pg);
    } else {
      if (child1 != null) {
        child1.draw(col, pg);
      }
      if (child2 != null) {
        child2.draw(col, pg);
      }
    }
  }


  SliceBox getMesh(float f) {
    if (f<=0) {   
      return invTMesh;
    } else if (f>=level) {   
      return mesh;
    } else {

      Slice p = this;
      float fracf;
      Transform T=new Transform();
      do {
        if (p.parentToChild!=null) {
          fracf=constrain((float)(p.level-f), 0.0, 1.0);
          T.addTransform(p.parentToChild.getInverseTransform(fracf));
        }
        p = p.parent;
      } while (p != null && f<p.level);

      T.apply(mesh, dynMesh);

      return dynMesh;
    }
  }
}
