static class MeshData {
  float[][] vertexArray;
  int[][] faceArray;
  int[] halfedgePairArray;
  color[] faceColor;
  int[] faceTextureIds;
  float[][] UVs;

  MeshData(float[][] vertexArray, int[][] faceArray, int[] halfedgePairArray, color[] faceColor) {
    this.vertexArray=vertexArray;
    this.faceArray=faceArray;
    this.halfedgePairArray=halfedgePairArray;
    this.faceColor=faceColor;
    this.faceTextureIds=null;
    this.UVs=null;
  }

  MeshData(float[][] vertexArray, int[][] faceArray, int[] halfedgePairArray, color[] faceColor, int[] faceTextureIds, float[][] UVs ) {
    this.vertexArray=vertexArray;
    this.faceArray=faceArray;
    this.halfedgePairArray=halfedgePairArray;
    this.faceColor=faceColor;
    this.faceTextureIds=faceTextureIds;
    this.UVs=UVs;
  }
}

static class MeshDataFactory {

  static MeshData createBoxWithCenterAndSize(float x, float y, float z, float width, float height, float depth, color col) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] faceTextureIds=new int[]{1, 2, 3, 4, 5, 6};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] UVs=new float[][]{{0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+vertices[i][0]*width;
      scaledVertices[i][1]=y+vertices[i][1]*height;
      scaledVertices[i][2]=z+vertices[i][2]*depth;
    }
    return new MeshData(scaledVertices, faces, halfedgePairs, new color[]{col, col, col, col, col, col}, faceTextureIds, UVs);
  }

  static MeshData createBoxWithCornerAndSize(float x, float y, float z, float width, float height, float depth, color col) {
    float[][] vertices=new float[][]{{-0.5, -0.5, -0.5}, {0.5, -0.5, -0.5}, {0.5, 0.5, -0.5}, {-0.5, 0.5, -0.5}, {-0.5, -0.5, 0.5}, {0.5, -0.5, 0.5}, {0.5, 0.5, 0.5}, {-0.5, 0.5, 0.5}};
    int[][] faces=new int[][]{{0, 1, 2, 3}, {7, 6, 5, 4}, {1, 0, 4, 5}, {3, 2, 6, 7}, {2, 1, 5, 6}, {0, 3, 7, 4}};
    int[] faceTextureIds=new int[]{1, 2, 3, 4, 5, 6};
    int[] halfedgePairs=new int[]{8, 16, 12, 20, 14, 18, 10, 22, 0, 23, 6, 17, 2, 19, 4, 21, 1, 11, 5, 13, 3, 15, 7, 9};
    float[][] UVs=new float[][]{{0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}, {0, 0}, {1, 0}, {1, 1}, {0, 1}};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+(0.5+vertices[i][0])*width;
      scaledVertices[i][1]=y+(0.5+vertices[i][1])*height;
      scaledVertices[i][2]=z+(0.5+vertices[i][2])*depth;
    }
    return new MeshData(scaledVertices, faces, halfedgePairs, new color[]{col, col, col, col, col, col}, faceTextureIds, UVs);
  }

  static MeshData createOctahedronWithCenterAndSize(float x, float y, float z, float width, float height, float depth, color col) {
    float[][] vertices=new float[][]{{-0.5, 0, 0}, {0, 0.5, 0}, {0.5, 0, 0}, {0, -0.5, 0}, {0, 0, 0.5}, {0, 0, -0.5}};
    int[][] faces=new int[][]{{0, 1, 4}, {1, 2, 4}, {2, 3, 4}, {3, 0, 4}, {1, 0, 5}, {2, 1, 5}, {3, 2, 5}, {0, 3, 5}};
    int[] halfedgePairs=new int[]{12, 5, 10, 15, 8, 1, 18, 11, 4, 21, 2, 7, 0, 23, 16, 3, 14, 19, 6, 17, 22, 9, 20, 13};
    float[][] scaledVertices=new float[vertices.length][3];
    for (int i=0; i<vertices.length; i++) {
      scaledVertices[i][0]=x+vertices[i][0]*width;
      scaledVertices[i][1]=y+vertices[i][1]*height;
      scaledVertices[i][2]=z+vertices[i][2]*depth;
    }
    return new MeshData(scaledVertices, faces, halfedgePairs, new color[]{col, col, col, col, col, col, col, col});
  }


  static MeshData createPrismWithCenterRadiusAndHeight(int N, float x, float y, float z, float radius, float height, color col) {
    return createPrismWithCenterRadiusRangeAndHeight(N, x, y, z, radius, radius, height, col);
  }

  static MeshData createPrismWithCenterRadiusRangeAndHeight(int N, float x, float y, float z, float minRadius, float maxRadius, float height, color col) {
    float[][] vertices=new float[2*N][3];

    float radius;
    for (int i=0; i<N; i++) {
      radius=(float)Math.random()*(maxRadius- minRadius);
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
    return create(vertices, faces, cols);
  }

  static MeshData create(float[][] vertexArray, int[][] faceArray, int[] col) {
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
    return new MeshData(vertexArray, faceArray, halfedgePairArray, col);
  }
}
