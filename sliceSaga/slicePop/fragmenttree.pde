class FragmentTree {
  ArrayList<Fragment> roots;

  FragmentTree(SliceMesh mesh) {
    roots=new ArrayList<Fragment>();
    roots.add(new Fragment(mesh));
  }

  FragmentTree(ArrayList<SliceMesh> meshes) {
    roots=new ArrayList<Fragment>();
    for (SliceMesh mesh : meshes) {
      roots.add(new Fragment(mesh));
    }
  }

  FragmentTree(SliceMesh... meshes) {
    roots=new ArrayList<Fragment>();
    for (SliceMesh mesh : meshes) {
      roots.add(new Fragment(mesh));
    }
  }

  void split(Transformation M, color col, color col2) {
    for (Fragment root : roots) {
      root.split(M, col, col2);
    }
  }

  void setPhase(float f) {
    for (Fragment root : roots) {
      root.setPhase(f);
    }
  }

  float[] getExtents() {
    float[] extents=new float[]{1000000, 1000000, 1000000, -1000000, -1000000, -1000000};
    for (Fragment root : roots) {
      root.addExtents(extents);
    }
    return extents;
  }

  void draw() {
    for (Fragment root : roots) {
      root.draw();
    }
  }
  
   void draw(PImage[] textures) {
    for (Fragment root : roots) {
      root.draw(textures);
    }
  }

  float minDistance(Plane P) {
    float minDistance=1000000;
    for (Fragment root : roots) {
      minDistance=min(minDistance, root.minDistance(P));
    }
    return minDistance;
  }
}



class Fragment {
  Fragment parent;
  Fragment child1, child2;
  Transformation parentToChild;
  SliceMesh mesh;
  SliceMesh invTMesh;
  SliceMesh dynMesh;
  SliceMesh drawMesh;
  int level;

  Fragment(SliceMesh mesh) {
    this.mesh = mesh.copy();
    invTMesh = mesh.copy();
    dynMesh = mesh.copy();
    parentToChild = null;
    parent = null;
    child1 = null;
    child2 = null;
    level = 0;
  }

  Fragment(SliceMesh mesh, Fragment parent, Transformation parentToChild) {
    this.mesh = mesh.copy();
    dynMesh= mesh.copy();
    this.parentToChild = parentToChild;
    this.parent = parent;
    invTMesh = mesh.copy();
    Fragment p = this;
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
      SliceMesh split1=mesh.copy();
      SliceMesh split2=mesh.copy();
      split1.slice(M.plane, 0.0, col);
      split2.slice(M.plane.flip(), 0.0, col2);
      if (split1.vertices.size() > 0 && split1.isValid()) {
        child1 = new Fragment(split1, this, null);
      }
      if (split2.vertices.size() > 0 && split2.isValid()) {
        M.getTransform(1.0).apply(split2);
        child2 = new Fragment(split2, this, M);
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
    if (((child1 == null) && (child2 == null))||f<=level) {
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
  
  void draw(PImage[] textures) {
    if (drawMesh!=null) {
      drawMesh.draw(textures);
    } else {
      if (child1 != null) {
        child1.draw(textures);
      }
      if (child2 != null) {
        child2.draw(textures);
      }
    }
  }

  SliceMesh getMesh(float f) {
    if (f<=0) {   
      return invTMesh;
    } else if (f>=level) {   
      return mesh;
    } else {
      Fragment p = this;
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
