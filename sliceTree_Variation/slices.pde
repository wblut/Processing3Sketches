class SliceTree {
  ArrayList<Slice> roots;
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

  void split(Transformation M, color col) {
    for (Slice root : roots) {
      root.split(M, col);
    }
  }

  void draw(double f) {
    for (Slice root : roots) {
      root.draw(f);
    }
  }
}



class Slice {
  Slice parent;
  Slice child1, child2;
  Transformation parentToChild;
  SliceBox mesh;
  SliceBox invTMesh;
  SliceBox dynMesh;
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

  void split(Transformation M, color col) {
    if ((child1 == null) && (child2 == null)) {
      SliceBox split1=mesh.copy();
      SliceBox split2=mesh.copy();
      split1.slice(M.plane, 0.0,col);
      split2.slice(M.plane.flip(), 0.0, col);
      if (split1.vertices.size() > 0 && split1.isValid()) {
        child1 = new Slice(split1, this, null);
      }
      if (split2.vertices.size() > 0 && split2.isValid()) {
        M.getTransform(1.0).apply(split2);
        child2 = new Slice(split2, this, M);
      }
    } else {
      if (child1 != null) {
        child1.split(M,col);
      }
      if (child2 != null) {
        child2.split(M,col);
      }
    }
  }


  void draw(double f) {
    if (((child1 == null) && (child2 == null))||f<=level) {
      SliceBox m = getMesh(f);
      m.draw();
    } else {
      if (child1 != null) {
        child1.draw(f);
      }
      if (child2 != null) {
        child2.draw(f);
      }
    }
  }

  SliceBox getMesh(double f) {
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
