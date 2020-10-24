float[][] vertSegments;
float[][] horSegments;
int currentI, currentJ;


void setup() {
  size(1000, 1000, P2D);
  smooth(16);
  //line thickness of vertical lines of the grid (41 lines of 40 segments each)
  vertSegments=new float[41][40];
  //line thickness of horizontal lines of the grid (41 lines of 40 segments each)
  horSegments=new float[41][40];
  //start point
  currentI=20;
  currentJ=20;
}

void takeStep() {
  checkBounds();
  int direction =(int)random(4.0);
  int step=(int)random(6.0)+1;
  switch(direction) {
  case 0:
    for (int i=max(0, currentI-step); i<currentI; i++) {
      horSegments[currentJ][i]+=1;
    }
    currentI-=step;
    break;
  case 1:
    for (int i=currentI; i<min(39, currentI+step); i++) {
      horSegments[currentJ][i]+=1;
    }
    currentI+=step;
    break;
  case 2:
    for (int j=max(0, currentJ-step); j<currentJ; j++) {
      vertSegments[currentI][j]+=1;
    }
    currentJ-=step;
    break;
  case 3:
    for (int j=currentJ; j<min(39, currentJ+step); j++) {
      vertSegments[currentI][j]+=1;
    }
    currentJ+=step;
    break;
  default:
  }
}


void checkBounds() {
  //if outside circle, start back at center
  if (sq(currentI-20)+sq(currentJ-20)>256) {
    currentI=(int)random(10,31);
    currentJ=(int)random(10,31);
  }
}


void draw() {
  background(255);
  translate(width/2, height/2);
  stroke(0);
  strokeWeight(1.0);
  ellipse(0, 0, 800, 800);
  drawVertSegments();
  drawHorSegments();

  takeStep();
  reduce();
}

void reduce() {
  for (int i=0; i<=40; i++) {
    for (int j=0; j<40; j++) {    
      vertSegments[i][j]=max(0.0, vertSegments[i][j]-0.01);
      horSegments[i][j]=max(0.0, horSegments[i][j]-0.01);
    }
  }
}




void drawVertSegments() {
  for (int i=0; i<=40; i++) {
    for (int j=0; j<40; j++) {
      if (vertSegments[i][j]>0) {
        strokeWeight(vertSegments[i][j]);
        line(i*25-500, j*25-500, i*25-500, j*25-475);
      }
    }
  }
}

void drawHorSegments() {
  for (int i=0; i<40; i++) {
    for (int j=0; j<=40; j++) {
      if (horSegments[j][i]>0) {
        strokeWeight(horSegments[j][i]/0.75);
        line(i*25-500, j*25-500, i*25-475, j*25-500);
      }
    }
  }
}

void keyPressed() {
  if (key=='r') {
    vertSegments=new float[41][40];
    horSegments=new float[41][40];
    currentI=20;
    currentJ=20;
  }
}
