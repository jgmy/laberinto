float[][] points={
  {0,0},{4,0},{5,1},{6,0},{11,0},
  {11,1},{10,1},{10,5},{9,5},{9,1},
  {8,1},{8,5},{6,5},{5,4},{4,5},
  {0,5},
};
float[][] hole1={
  {1,1},{1,2},{3,2},{3,3},{1,3},
  {1,4},{3,4},{4.5,2.5},{3,1},
};
float[][] hole2={
  {5.5,2.5},{7,4},{7,1},
};
PShape EXIT;

void makeExitSign(){
  PShape SH1,SH;
  int f;
  
  EXIT=createShape(GROUP);
  SH=createShape();
  SH.beginShape();
  
  for(f=0;f<points.length;f++){
    SH.vertex(points[f][0],points[f][1],-5);
  }
  SH.beginContour();
  for(f=0;f<hole1.length;f++){
    SH.vertex(hole1[f][0],hole1[f][1],-5);
  };
  SH.endContour();
  SH.beginContour();
  for(f=0;f<hole2.length;f++){
    SH.vertex(hole2[f][0],hole2[f][1],-5);
  }
  SH.endContour();
  SH.endShape(CLOSE);
  
  SH1=createShape();
  SH1.beginShape();
  for(f=0;f<points.length;f++){
    SH1.vertex(points[f][0],points[f][1],5);
  }
  SH1.beginContour();
  for(f=0;f<hole1.length;f++){
    SH1.vertex(hole1[f][0],hole1[f][1],5);
  };
  SH1.endContour();
  SH1.beginContour();
  for(f=0;f<hole2.length;f++){
    SH1.vertex(hole2[f][0],hole2[f][1],5);
  }
  SH1.endContour();
  SH1.endShape(CLOSE);
  EXIT.addChild(SH);
  EXIT.addChild(SH1);
  recorreshape(EXIT, points,-5,5);
  recorreshape(EXIT, hole1,-5,5);
  recorreshape(EXIT, hole2,-5,5);
 }

void recorreshape(PShape out,float[][] p,float z1, float z2){
  int g;
  PShape t;
  
  for (int f=0;f<p.length;f++){
    t=createShape();
   
    t.beginShape();
    t.fill(200,255,200);
    g=(f+1)% p.length;
    t.vertex(p[f][0],p[f][1],z1);
    t.vertex(p[f][0],p[f][1],z2);
    t.vertex(p[g][0],p[g][1],z2);
    t.vertex(p[g][0],p[g][1],z1);
    t.endShape();
    out.addChild(t);
  }
  
}