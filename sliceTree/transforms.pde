static int ROTATION=1;
static int TRANSLATION=0;
static int SHEAR=2;
static int STRETCH=3;


class Transformation {
  Transform T;
  Plane plane;
  PVector origin;
  PVector normal;
  PVector direction;
  PVector reverseDirection;
  float amount;
  int type;//0==translation, 1==rotation, 2==shear
  int level;
  float explode;
  float explodePerLevel;

//rotation or stretch
  Transformation(PVector origin, PVector axis, float angle, int type, float explode, float explodePerLevel) {
    this.origin=origin.copy();
    this.normal=axis.copy();
    
    this.normal.normalize();
    this.plane = new Plane(this.origin, this.normal); 
    this.amount=angle; 
    this.type=type;
    assert(type==ROTATION|| type==STRETCH);
    this.direction=this.normal;
    this.reverseDirection=new PVector(-this.direction.x,-this.direction.y,-this.direction.z);
    this.level=0;
    this.explode=explode;
    this.explodePerLevel=explodePerLevel;
  }

//translation or shear
  Transformation(PVector origin, PVector normal, float amount, PVector direction, int type, float explode, float explodePerLevel) {
    this.origin=origin.copy();
    this.normal=normal.copy();
    this.normal.normalize();
     this.plane = new Plane(this.origin, this.normal); 
    this.type=type;
    assert(type==TRANSLATION || type==SHEAR);
    this.amount=amount; 
    this.direction =direction.copy();
    this.direction.normalize();
    this.reverseDirection=new PVector(-this.direction.x,-this.direction.y,-this.direction.z);
    this.level=0;
     this.explode=explode;
    this.explodePerLevel=explodePerLevel;
  }



  Transform getTransform(float f) {
 
   float fAmount=f*amount;
    T = new Transform(); 
    if (type==TRANSLATION) {
      T.addTranslate(fAmount,direction);
      T.addTranslate(f*(explode+level*explodePerLevel),normal);
    } else if (type==ROTATION) {
      T.addRotateAboutAxis(fAmount, origin, direction);
      T.addTranslate(f*(explode+level*explodePerLevel),normal);
    } else if (type==SHEAR) {
      T.addShear(origin, normal, direction, radians((float)fAmount));
      T.addTranslate(f*(explode+level*explodePerLevel),normal);
    } else if (type==STRETCH) {
      fAmount=1.0+f*(amount-1.0);
     T.addStretch(origin, normal, fAmount);
      T.addTranslate(f*(explode+level*explodePerLevel),normal);
    }
    return T;
  }

  Transform getInverseTransform(float f) {
    float fAmount=f*amount;
    T = new Transform(); 
    if (type==TRANSLATION) {
      T.addTranslate(-f*(explode+level*explodePerLevel),normal);
      T.addTranslate(fAmount,reverseDirection);
    } else if (type==ROTATION) {
      T.addTranslate(-f*(explode+level*explodePerLevel),normal);
      T.addRotateAboutAxis(fAmount, origin, reverseDirection);
    } else if (type==SHEAR) {
      T.addTranslate(-f*(explode+level*explodePerLevel),normal);
      T.addShear(origin, normal, reverseDirection, radians((float)fAmount));
    }  else if (type==STRETCH) {
      fAmount=1.0+f*(amount-1.0);
       T.addTranslate(-f*(explode+level*explodePerLevel),normal);
     T.addStretch(origin, normal, 1.0/fAmount);
     
    }
    return T;
  }
}







class Transform {
  float _xt, _yt, _zt, _wt;
  M44 T;
  M44 invT;

  Transform() {
    T = new M44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    invT = new M44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  }

  Transform(Transform Trans) {
    T = Trans.T.get();
    invT = Trans.invT.get();
  }

  Transform addTransform(Transform transform) {
    T = transform.T.mul(T);
    invT = invT.mul(transform.T);
    return this;
  }

  Transform addTranslate(PVector v) {
    T = new M44(1, 0, 0, v.x, 0, 1, 0, v.y, 0, 0, 1, v.z, 0, 0, 0, 1).mul(T);
    invT = invT.mul(new M44(1, 0, 0, -v.x, 0, 1, 0, -v.y, 0, 0, 1, -v.z, 0, 0, 0, 1));
    return this;
  }

  Transform addTranslate(float f, PVector v) {
    T = new M44(1, 0, 0, f * v.x, 0, 1, 0, f * v.y, 0, 0, 1, f * v.z, 0, 0, 0, 1).mul(T);
    invT = invT.mul(new M44(1, 0, 0, -f * v.x, 0, 1, 0, -f * v.y, 0, 0, 1, -f * v.z, 0, 0, 0, 1));
    return this;
  }


  Transform addScale(PVector s) {
    T = new M44(s.x, 0, 0, 0, 0, s.y, 0, 0, 0, 0, s.z, 0, 0, 0, 0, 1).mul(T);
    invT = invT.mul(new M44(1.0 / s.x, 0, 0, 0, 0, 1.0 / s.y, 0, 0, 0, 0, 1.0 / s.z, 0, 0, 0, 0, 1));
    return this;
  }

  Transform addScale(float sx, float sy, float sz) {
    T = new M44(sx, 0, 0, 0, 0, sy, 0, 0, 0, 0, sz, 0, 0, 0, 0, 1).mul(T);
    invT = invT.mul(new M44(1.0 / sx, 0, 0, 0, 0, 1.0 / sy, 0, 0, 0, 0, 1.0 / sz, 0, 0, 0, 0, 1));
    return this;
  }

  Transform addScale(float s) {
    T = new M44(s, 0, 0, 0, 0, s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1).mul(T);
    invT = invT.mul(new M44(1 / s, 0, 0, 0, 0, 1 / s, 0, 0, 0, 0, 1 / s, 0, 0, 0, 0, 1));
    return this;
  }


  Transform addRotateX(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    M44 tmp = new M44(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
    T = tmp.mul(T);
    invT = invT.mul(tmp.getTranspose());
    return this;
  }

  Transform addRotateY(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    M44 tmp = new M44(c, 0, s, 0, 0, 1, 0, 0, -s, 0, c, 0, 0, 0, 0, 1);
    T = tmp.mul(T);
    invT = invT.mul(tmp.getTranspose());
    return this;
  }

  Transform addRotateZ(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    M44 tmp = new M44(c, -s, 0, 0, s, c, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    T = tmp.mul(T);
    invT = invT.mul(tmp.getTranspose());
    return this;
  }


  Transform addRotateAboutOrigin(float angle, PVector axis) {
    PVector a = new PVector(axis.x, axis.y, axis.z);
    a.normalize();
    float s = sin(angle);
    float c = cos(angle);
    M44 tmp = new M44(a.x * a.x + (1.f - a.x * a.x) * c, 
      a.x * a.y * (1.f - c) - a.z * s, a.x * a.z * (1.f - c) + a.y * s, 0, 
      a.x * a.y * (1.f - c) + a.z * s, a.y * a.y + (1.f - a.y * a.y) * c, 
      a.y * a.z * (1.f - c) - a.x * s, 0, a.x * a.z * (1.f - c) - a.y * s, 
      a.y * a.z * (1.f - c) + a.x * s, a.z * a.z + (1.f - a.z * a.z) * c, 0, 0, 0, 0, 1);
    T = tmp.mul(T);
    invT = invT.mul(tmp.getTranspose());
    return this;
  }

  Transform addRotateAboutAxis(float angle, PVector p, PVector axis) {
    addTranslate(-1, p);
    addRotateAboutOrigin(angle, axis);
    addTranslate(p);
    return this;
  }

  Transform addRotateAboutAxis2P(float angle, PVector p, PVector q) {
    addTranslate(-1, p);
    addRotateAboutOrigin(angle, PVector.sub(q, p));
    addTranslate(p);
    return this;
  }

  Transform addShear(PVector origin, PVector normal, PVector v, float angle) {
    addTranslate(-1, origin);
    PVector lv = new PVector(v.x, v.y, v.z);
    lv.normalize();
    float tana = tan(angle);
    lv.mult(tana);
    M33 tmp = M33.tensor(lv.x, lv.y, lv.z, normal.x, normal.y, normal.z);
    M44 Tr = new M44(1 + tmp.m11, tmp.m12, tmp.m13, 0, tmp.m21, 1 + tmp.m22, tmp.m23, 0, tmp.m31, tmp.m32, 
      1 + tmp.m33, 0, 0, 0, 0, 1);
    T = Tr.mul(T);
    tana *= -1;
    Tr = new M44(1 - tmp.m11, -tmp.m12, -tmp.m13, 0, -tmp.m21, 1 - tmp.m22, -tmp.m23, 0, -tmp.m31, -tmp.m32, 
      1 - tmp.m33, 0, 0, 0, 0, 1);
    invT = invT.mul(Tr);
    addTranslate(origin);
    return this;
  }
  
Transform addStretch(PVector origin, PVector axis, float factor) {
  Plane P=new Plane(origin, axis);
    addFromWorldToCS(P.origin,P.u,P.v,P.normal);
    float invsqrt = 1.0 / sqrt(abs(factor));
    addScale(invsqrt, invsqrt, factor);
    addFromCSToWorld(P.origin,P.u,P.v,P.normal);
    return this;
  }
  
  Transform addFromCSToWorld(PVector origin, PVector X, PVector Y, PVector Z) {
    PVector ex2 = new PVector(1,0,0), ey2 = new PVector(0,1,0), ez2 =new PVector(0,0,1);
    PVector o2 = new PVector(0,0,0);
    float xx = ex2.dot(X);
    float xy = ex2.dot(Y);
    float xz = ex2.dot(Z);
    float yx = ey2.dot(X);
    float yy = ey2.dot(Y);
    float yz = ey2.dot(Z);
    float zx = ez2.dot(X);
    float zy = ez2.dot(Y);
    float zz = ez2.dot(Z);
    M44 tmp = new M44(xx, xy, xz, 0, yx, yy, yz, 0, zx, zy, zz, 0, 0, 0, 0, 1);
    M44 invtmp = new M44(xx, yx, zx, 0, xy, yy, zy, 0, xz, yz, zz, 0, 0, 0, 0, 1);
    T = tmp.mul(T);
    invT = invT.mul(invtmp);
    addTranslate(origin);
    return this;
  }

   Transform addFromWorldToCS(PVector origin, PVector X, PVector Y, PVector Z) {
    Transform tmp=new Transform();
    tmp.addFromCSToWorld(origin,X,Y,Z);
     T = tmp.invT.mul(T);
      invT = invT.mul(tmp.T);
    return this;
  }

  void inverse() {
    M44 tmp;
    tmp = T;
    T = invT;
    invT = tmp;
  }

  void clear() {
    T = new M44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    invT = new M44(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  }

  void apply(SliceBox sliceBox) {
    for (Vertex p : sliceBox.vertices) {
      _xt = T.m11 * p.x + T.m12 * p.y + T.m13 * p.z + T.m14;
      _yt = T.m21 * p.x + T.m22 * p.y + T.m23 * p.z + T.m24;
      _zt = T.m31 * p.x + T.m32 * p.y + T.m33 * p.z + T.m34;
      _wt = T.m41 * p.x + T.m42 * p.y + T.m43 * p.z + T.m44;
      _wt = 1.0 / _wt;
      p.x=_xt * _wt;
      p.y=_yt * _wt;
      p.z= _zt * _wt;
    }
  }
  
  void apply(SliceBox sliceBox, SliceBox target) {
    Vertex p,q;
    for (int i=0;i<sliceBox.vertices.size();i++) {
      p=sliceBox.vertices.get(i);
      _xt = T.m11 * p.x + T.m12 * p.y + T.m13 * p.z + T.m14;
      _yt = T.m21 * p.x + T.m22 * p.y + T.m23 * p.z + T.m24;
      _zt = T.m31 * p.x + T.m32 * p.y + T.m33 * p.z + T.m34;
      _wt = T.m41 * p.x + T.m42 * p.y + T.m43 * p.z + T.m44;
      _wt = 1.0 / _wt;
      q=target.vertices.get(i);
      q.x=_xt * _wt;
      q.y=_yt * _wt;
      q.z= _zt * _wt;
    }
  }

  void applyInv(SliceBox sliceBox) {
    for (Vertex p : sliceBox.vertices) {
      _xt = invT.m11 * p.x + invT.m12 * p.y + invT.m13 * p.z + invT.m14;
      _yt = invT.m21 * p.x + invT.m22 * p.y + invT.m23 * p.z + invT.m24;
      _zt = invT.m31 * p.x + invT.m32 * p.y + invT.m33 * p.z + invT.m34;
      _wt = invT.m41 * p.x + invT.m42 * p.y + invT.m43 * p.z + invT.m44;
      _wt = 1.0 / _wt;
      p.x=_xt * _wt;
      p.y=_yt * _wt;
      p.z= _zt * _wt;
    }
  }
}

static class M44 {
  float m11, m12, m13, m14;
  float m21, m22, m23, m24;
  float m31, m32, m33, m34;
  float m41, m42, m43, m44;


  M44() {
  }


  M44(float[][] matrix44) {
    m11 = matrix44[0][0];
    m12 = matrix44[0][1];
    m13 = matrix44[0][2];
    m14 = matrix44[0][3];
    m21 = matrix44[1][0];
    m22 = matrix44[1][1];
    m23 = matrix44[1][2];
    m24 = matrix44[1][3];
    m31 = matrix44[2][0];
    m32 = matrix44[2][1];
    m33 = matrix44[2][2];
    m34 = matrix44[2][3];
    m41 = matrix44[3][0];
    m42 = matrix44[3][1];
    m43 = matrix44[3][2];
    m44 = matrix44[3][3];
  }

  M44(float m11, float m12, float m13, float m14, float m21, 
    float m22, float m23, float m24, float m31, float m32, float m33, 
    float m34, float m41, float m42, float m43, float m44) {
    this.m11 = m11;
    this.m12 = m12;
    this.m13 = m13;
    this.m14 = m14;
    this.m21 = m21;
    this.m22 = m22;
    this.m23 = m23;
    this.m24 = m24;
    this.m31 = m31;
    this.m32 = m32;
    this.m33 = m33;
    this.m34 = m34;
    this.m41 = m41;
    this.m42 = m42;
    this.m43 = m43;
    this.m44 = m44;
  }

  void set(float[][] matrix44) {
    m11 = matrix44[0][0];
    m12 = matrix44[0][1];
    m13 = matrix44[0][2];
    m14 = matrix44[0][3];
    m21 = matrix44[1][0];
    m22 = matrix44[1][1];
    m23 = matrix44[1][2];
    m24 = matrix44[1][3];
    m31 = matrix44[2][0];
    m32 = matrix44[2][1];
    m33 = matrix44[2][2];
    m34 = matrix44[2][3];
    m41 = matrix44[3][0];
    m42 = matrix44[3][1];
    m43 = matrix44[3][2];
    m44 = matrix44[3][3];
  }


  void set(float m11, float m12, float m13, float m14, float m21, 
    float m22, float m23, float m24, float m31, float m32, float m33, 
    float m34, float m41, float m42, float m43, float m44) {
    this.m11 = m11;
    this.m12 = m12;
    this.m13 = m13;
    this.m14 = m14;
    this.m21 = m21;
    this.m22 = m22;
    this.m23 = m23;
    this.m24 = m24;
    this.m31 = m31;
    this.m32 = m32;
    this.m33 = m33;
    this.m34 = m34;
    this.m41 = m41;
    this.m42 = m42;
    this.m43 = m43;
    this.m44 = m44;
  }

  M44 get() {
    return new M44(m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44);
  }


  M44 mul(M44 m) {
    return new M44(m11 * m.m11 + m12 * m.m21 + m13 * m.m31 + m14 * m.m41, 
      m11 * m.m12 + m12 * m.m22 + m13 * m.m32 + m14 * m.m42, 
      m11 * m.m13 + m12 * m.m23 + m13 * m.m33 + m14 * m.m43, 
      m11 * m.m14 + m12 * m.m24 + m13 * m.m34 + m14 * m.m44, 
      m21 * m.m11 + m22 * m.m21 + m23 * m.m31 + m24 * m.m41, 
      m21 * m.m12 + m22 * m.m22 + m23 * m.m32 + m24 * m.m42, 
      m21 * m.m13 + m22 * m.m23 + m23 * m.m33 + m24 * m.m43, 
      m21 * m.m14 + m22 * m.m24 + m23 * m.m34 + m24 * m.m44, 
      m31 * m.m11 + m32 * m.m21 + m33 * m.m31 + m34 * m.m41, 
      m31 * m.m12 + m32 * m.m22 + m33 * m.m32 + m34 * m.m42, 
      m31 * m.m13 + m32 * m.m23 + m33 * m.m33 + m34 * m.m43, 
      m31 * m.m14 + m32 * m.m24 + m33 * m.m34 + m34 * m.m44, 
      m41 * m.m11 + m42 * m.m21 + m43 * m.m31 + m44 * m.m41, 
      m41 * m.m12 + m42 * m.m22 + m43 * m.m32 + m44 * m.m42, 
      m41 * m.m13 + m42 * m.m23 + m43 * m.m33 + m44 * m.m43, 
      m41 * m.m14 + m42 * m.m24 + m43 * m.m34 + m44 * m.m44);
  }



  M44 inverse() {
    float[][] m = new float[][] { { m11, m12, m13, m14 }, { m21, m22, m23, m24 }, { m31, m32, m33, m34 }, 
      { m41, m12, m43, m44 } };
    int[] indxc = new int[4];
    int[] indxr = new int[4];
    int[] ipiv = new int[4];
    float[][] minv = new float[4][4];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        minv[i][j] = m[i][j];
      }
    }
    for (int i = 0; i < 4; i++) {
      int irow = -1, icol = -1;
      float big = 0.;
      // Choose pivot
      for (int j = 0; j < 4; j++) {
        if (ipiv[j] != 1) {
          for (int k = 0; k < 4; k++) {
            if (ipiv[k] == 0) {
              if (abs(minv[j][k]) >= big) {
                big = abs(minv[j][k]);
                irow = j;
                icol = k;
              }
            } else if (ipiv[k] > 1) {
              return null;
            }
          }
        }
      }
      ++ipiv[icol];
      // Swap rows _irow_ and _icol_ for pivot
      float tmp;
      if (irow != icol) {
        for (int k = 0; k < 4; ++k) {
          tmp = minv[irow][k];
          minv[irow][k] = minv[icol][k];
          minv[icol][k] = tmp;
        }
      }
      indxr[i] = irow;
      indxc[i] = icol;
      if (minv[icol][icol] == 0.) {
        return null;
      }
      // Set $m[icol][icol]$ to one by scaling row _icol_ appropriately
      float pivinv = 1.0 / minv[icol][icol];
      minv[icol][icol] = 1.0;
      for (int j = 0; j < 4; j++) {
        minv[icol][j] *= pivinv;
      }
      // Subtract this row from others to zero out their columns
      for (int j = 0; j < 4; j++) {
        if (j != icol) {
          float save = minv[j][icol];
          minv[j][icol] = 0;
          for (int k = 0; k < 4; k++) {
            minv[j][k] -= minv[icol][k] * save;
          }
        }
      }
    }
    float tmp;
    // Swap columns to reflect permutation
    for (int j = 3; j >= 0; j--) {
      if (indxr[j] != indxc[j]) {
        for (int k = 0; k < 4; k++) {
          tmp = minv[k][indxr[j]];
          minv[k][indxr[j]] = minv[k][indxc[j]];
          minv[k][indxc[j]] = tmp;
        }
      }
    }
    M44 I = new M44(minv);
    return I;
  }

  void transpose() {
    float tmp = m12;
    m12 = m21;
    m21 = tmp;
    tmp = m13;
    m13 = m31;
    m31 = tmp;
    tmp = m14;
    m14 = m41;
    m41 = tmp;
    tmp = m23;
    m23 = m32;
    m32 = tmp;
    tmp = m24;
    m24 = m42;
    m42 = tmp;
    tmp = m34;
    m34 = m43;
    m43 = tmp;
  }

  M44 getTranspose() {
    return new M44(m11, m21, m31, m41, m12, m22, m32, m42, m13, m23, m33, m43, m14, m24, m34, m44);
  }
}

static class M33 {
  float m11, m12, m13;
  float m21, m22, m23;
  float m31, m32, m33;

  M33() {
  }


  M33(float[][] matrix33) {
    m11 = matrix33[0][0];
    m12 = matrix33[0][1];
    m13 = matrix33[0][2];
    m21 = matrix33[1][0];
    m22 = matrix33[1][1];
    m23 = matrix33[1][2];
    m31 = matrix33[2][0];
    m32 = matrix33[2][1];
    m33 = matrix33[2][2];
  }

  M33(float m11, float m12, float m13, float m21, float m22, 
    float m23, float m31, float m32, float m33) {
    this.m11 = m11;
    this.m12 = m12;
    this.m13 = m13;
    this.m21 = m21;
    this.m22 = m22;
    this.m23 = m23;
    this.m31 = m31;
    this.m32 = m32;
    this.m33 = m33;
  }





  void set(float m11, float m12, float m13, float m21, float m22, 
    float m23, float m31, float m32, float m33) {
    this.m11 = m11;
    this.m12 = m12;
    this.m13 = m13;
    this.m21 = m21;
    this.m22 = m22;
    this.m23 = m23;
    this.m31 = m31;
    this.m32 = m32;
    this.m33 = m33;
  }

  void set(M33 m) {
    m11 = m.m11;
    m12 = m.m12;
    m13 = m.m13;
    m21 = m.m21;
    m22 = m.m22;
    m23 = m.m23;
    m31 = m.m31;
    m32 = m.m32;
    m33 = m.m33;
  }

  M33 get() {
    return new M33(m11, m12, m13, m21, m22, m23, m31, m32, m33);
  }

  static M33 tensor(float ux, float uy, float uz, float vx, 
    float vy, float vz) {
    return new M33( ux * vx, ux * vy, ux * vz, uy * vx, uy * vy, uy * vz, 
      uz * vx, uz * vy, uz * vz);
  }




  void div(float f) {
    float invf = 1.0 / f;
    m11 *= invf;
    m12 *= invf;
    m13 *= invf;
    m21 *= invf;
    m22 *= invf;
    m23 *= invf;
    m31 *= invf;
    m32 *= invf;
    m33 *= invf;
  }

  M33 mul(M33 n) {
    return new M33(m11 * n.m11 + m12 * n.m21 + m13 * n.m31, m11 * n.m12 + m12 * n.m22 + m13 * n.m32, 
      m11 * n.m13 + m12 * n.m23 + m13 * n.m33, m21 * n.m11 + m22 * n.m21 + m23 * n.m31, 
      m21 * n.m12 + m22 * n.m22 + m23 * n.m32, m21 * n.m13 + m22 * n.m23 + m23 * n.m33, 
      m31 * n.m11 + m32 * n.m21 + m33 * n.m31, m31 * n.m12 + m32 * n.m22 + m33 * n.m32, 
      m31 * n.m13 + m32 * n.m23 + m33 * n.m33);
  }



  float det() {
    return m11 * (m22 * m33 - m23 * m32) + m12 * (m23 * m31 - m21 * m33) + m13 * (m21 * m32 - m22 * m31);
  }


  void transpose() {
    float tmp = m12;
    m12 = m21;
    m21 = tmp;
    tmp = m13;
    m13 = m31;
    m31 = tmp;
    tmp = m23;
    m23 = m32;
    m32 = tmp;
  }

  M33 getTranspose() {
    return new M33(m11, m21, m31, m12, m22, m32, m13, m23, m33);
  }


  M33 inverse() {
    float d = det();
    if (abs(d)<0.000001) {
      return null;
    }
    M33 I = new M33(m22 * m33 - m23 * m32, m13 * m32 - m12 * m33, m12 * m23 - m13 * m22, 
      m23 * m31 - m21 * m33, m11 * m33 - m13 * m31, m13 * m21 - m11 * m23, m21 * m32 - m22 * m31, 
      m12 * m31 - m11 * m32, m11 * m22 - m12 * m21);
    I.div(d);
    return I;
  }

  @Override
    String toString() {
    return "M33: " + m11 + ", " + m12 + ", " + m13 + ", " + m21 + ", " + m22 + ", " + m23 + ", " + m31 + ", " + m32
      + ", " + m33;
  }
}
