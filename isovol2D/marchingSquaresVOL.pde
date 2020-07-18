import java.util.Map;
import java.util.HashMap;
import java.util.List;

Map<Integer, Point> xedges;
Map<Integer, Point> yedges;
Map<Integer, Point> vertices;
float isolevelmin;
float isolevelmax;
List<Triangle> triangles;

int index(int i, int j) {
  return i+1 +(resx+2)*(j+1);
}



Point vertex(final int i, final int j, final Point offset) {
  Point vertex = vertices.get(index(i, j));
  if (vertex != null) {
    return vertex;
  }
  vertex = new Point(i * dx+offset.x, j * dy+offset.y, zFactor * getValue(i, j)+offset.z);
  vertices.put(index(i, j), vertex);
  return vertex;
}

Point interp(final float isolevel, final Point p1, final Point p2, final float valp1, 
  final float valp2, Point offset) {
  if (isolevel==valp1) {
    return new Point(p1.x +offset.x, p1.y+offset.y, zFactor * isolevel);
  }
  if (isolevel==valp2) {
    return new Point(p2.x+offset.x, p2.y+offset.y, zFactor * isolevel);
  }
  if (valp1==valp2) {
    return new Point(p1.x+offset.x, p1.y+offset.y, zFactor * isolevel);
  }
  float mu = (isolevel - valp1) / (valp2 - valp1);
  return new Point(p1.x + mu * (p2.x - p1.x)+offset.x, p1.y + mu * (p2.y - p1.y)+offset.y, zFactor * isolevel);
}

Point xedge(final int i, final int j, final Point offset, final float isolevel) {
  Point xedge = xedges.get(index(i, j));
  if (xedge != null) {
    return xedge;
  }
  final Point p0 = new Point(i * dx, j * dy, 0);
  final Point p1 = new Point(i * dx + dx, j * dy, 0);
  final float val0 = getValue(i, j);
  final float val1 = getValue(i + 1, j);
  xedge = interp(isolevel, p0, p1, val0, val1, offset);
  xedges.put(index(i, j), xedge);
  return xedge;
}

Point yedge(final int i, final int j, final Point offset, final float isolevel) {
  Point yedge = yedges.get(index(i, j));
  if (yedge != null) {
    return yedge;
  }
  final Point p0 = new Point(i * dx, j * dy, 0);
  final Point p1 = new Point(i * dx, j * dy + dy, 0);
  final float val0 = getValue(i, j);
  final float val1 = getValue(i, j + 1);
  yedge =interp(isolevel, p0, p1, val0, val1, offset);
  yedges.put(index(i, j), yedge);
  return yedge;
}

int classifyCell(final int i, final int j) {
  if (i < 0 || j < 0 || i >= resx || j >= resy) {
    return -1;
  }
  digits = new int[8];
  int cubeindex = 0;
  int offset = 1;
  if (getValue(i, j) > isolevelmax) {
    cubeindex += 2 * offset;
    digits[0] = POSITIVE;
  } else if (getValue(i, j) >= isolevelmin) {
    cubeindex += offset;
    digits[0] = EQUAL;
  }
  offset *= 3;
  if (getValue(i + 1, j) > isolevelmax) {
    cubeindex += 2 * offset;
    digits[1] = POSITIVE;
  } else if (getValue(i + 1, j) >= isolevelmin) {
    cubeindex += offset;
    digits[1] = EQUAL;
  }
  offset *= 3;
  if (getValue(i, j + 1) > isolevelmax) {
    cubeindex += 2 * offset;
    digits[2] = POSITIVE;
  } else if (getValue(i, j + 1) >= isolevelmin) {
    cubeindex += offset;
    digits[2] = EQUAL;
  }
  offset *= 3;
  if (getValue(i + 1, j + 1) > isolevelmax) {
    cubeindex += 2 * offset;
    digits[3] = POSITIVE;
  } else if (getValue(i + 1, j + 1) >= isolevelmin) {
    cubeindex += offset;
    digits[3] = EQUAL;
  }
  return cubeindex;
}

List<Triangle> getTriangles(float isomin, float isomax, color col) {
  isolevelmin=isomin;
  isolevelmax=isomax;
  xedges = new HashMap<Integer, Point>();
  yedges = new HashMap<Integer, Point>();
  vertices = new HashMap<Integer, Point>();
  final Point offset = new Point(cx - 0.5 * resx * dx, cy - 0.5 * resy * dy, 0);
  triangles = new ArrayList<Triangle>();
  for (int i = 0; i < resx; i++) {
    for (int j = 0; j < resy; j++) {
      triangulate(i, j, classifyCell(i, j), offset, col);
    }
  }
  return triangles;
}

void triangulate(final int i, final int j, final int cubeindex, final Point offset, color col) {
  final int[] indices = entries[cubeindex];
  final int numtris = indices[0];
  int currentindex = 1;
  for (int t = 0; t < numtris; t++) {
    final Point v2 = getIsoVertex(indices[currentindex++], i, j, offset);
    final Point v1 = getIsoVertex(indices[currentindex++], i, j, offset);
    final Point v3 = getIsoVertex(indices[currentindex++], i, j, offset);
    triangles.add(new Triangle(v1, v2, v3,col));
  }
 
}

Point getIsoVertex(final int isopointindex, final int i, final int j, final Point offset) {
  if (isovertices[isopointindex][0] == ONVERTEX) {
    switch (isovertices[isopointindex][1]) {
    case 0:
      return vertex(i, j, offset);
    case 1:
      return vertex(i + 1, j, offset);
    case 2:
      return vertex(i, j + 1, offset);
    case 3:
      return vertex(i + 1, j + 1, offset);
    default:
      return null;
    }
  } else if (isovertices[isopointindex][0] == ONEDGE) {
    if (isovertices[isopointindex][2] == 0) {
      switch (isovertices[isopointindex][1]) {
      case 0:
        return xedge(i, j, offset, isolevelmin);
      case 1:
        return yedge(i, j, offset, isolevelmin);
      case 2:
        return yedge(i + 1, j, offset, isolevelmin);
      case 3:
        return xedge(i, j + 1, offset, isolevelmin);
      default:
        return null;
      }
    } else {
      switch (isovertices[isopointindex][1]) {
      case 0:
        return xedge(i, j, offset, isolevelmax);
      case 1:
        return yedge(i, j, offset, isolevelmax);
      case 2:
        return yedge(i + 1, j, offset, isolevelmax);
      case 3:
        return xedge(i, j + 1, offset, isolevelmax);
      default:
        return null;
      }
    }
  }
  return null;
}
