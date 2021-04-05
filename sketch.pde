/* This intends to be a 3d labyrinth 
 made with Processing
 */



/* map dimensions*/
int alto=40;
int ancho=40;
float h, w, xx, yy;
/* 3d camera float direction*/
float fdir=0;
/* map generation x and y */
int x, y;

/* map generation status (true=ended)*/
boolean acabado=false;
/*Position of labrynth exits */
int salidaX=-1, salidaY=-1;

/* map matrix (array) */
int[][] mapa=new int[alto][ancho];
/* int directions. 0=N, 1=E*/
static PVector[] dir={
  new PVector(0, -1), 
  new PVector(1, 0), 
  new PVector(0, 1), 
  new PVector(-1, 0), 
};

/* Map tiles. Hardcoded from -1 to 3 */
static final int MAPA_WALL=-1;
/* Note these depend on PVector dir */
static final int MAPA_N=0;
static final int MAPA_E=1;
static final int MAPA_S=2;
static final int MAPA_W=3;
/* Also, it is hardcoded that dirs< 4*/
/* You can redefine the following:*/
static final int MAPA_START =5;
static final int MAPA_PASILLO =8;
static final int MAPA_OUTSIDE =9;
static final int MAPA_EXIT=10;

/* for debug */
String[] messages={};

/* 3d canvas*/
PGraphics lienzo;

/* configuration*/
void setup() {
  int f, g;

  /* 2D screen*/
  size(1000, 1000, P2D);
  /* 3d canvas*/
  lienzo=createGraphics(1000, 1000, P3D);

  /* map generator tile height and width*/
  /* w is used for 3d cube size, also */
  w=width/ancho;
  h=height/alto;
  //printms(w);
  //printms(h);

  /* initialize map */
  /* inside is -1, borders are 9.*/
  for (f=0; f<alto; f++) {
    mapa[f][0]=MAPA_OUTSIDE;
    mapa[f][ancho-1]=MAPA_OUTSIDE;
    for (g=1; g<(ancho-1); g++) {
      mapa[f][g]=((f==0|f==(alto-1)) ? MAPA_OUTSIDE: MAPA_WALL);
    }
  }

  x=ancho/2;    /* map generator start x*/
  xx=width/2;   /*3d view start x*/
  y=alto/2;     /*map generator start y*/
  yy=height/2;  /* 3d view start y*/
  mapa[x][y]=5; /* marks start/end tile*/

  //make some shapes
  makeShapes();
}

void draw() {

  int curDir=-1;
  if (acabado==false) {
    /* generate map until done */
    curDir=generar();
    if (curDir!=-1) {
      // Set fdir to look at an exit on
      // first frame.
      fdir=HALF_PI * ((curDir+1)%4);
    }
  } else {

    /* if map is done, show 3d view */
    /* tresd  is 3d spelt in Spanish*/
    tresde();
  }
  showMessages();
}
/* Show 3d view */
void tresde() {
  /* variables for for... loop */
  float ix, iy;
  /* we draw in a 3d canvas
   so we can mix 3d and 2d
   */
  lienzo.beginDraw();
  lienzo.background(128);
  lienzo.perspective(HALF_PI, 1.0, .5, w*40.0);
  lienzo.ambientLight(102, 102, 102);
  lienzo.directionalLight(xx, yy, 0, 0, 0, 1);

  final boolean show3d=true;
  if (!show3d) {
    /*Experimental - disable 
     fist person
     for debug purposes
     */
    lienzo.pushMatrix();
    lienzo.translate(xx, yy);
    lienzo.sphere(w);
    lienzo.popMatrix();
  } else {
    /* Normal: 1st person view */
    lienzo.camera(xx, yy, 0, xx+cos(fdir), yy+sin(fdir), 0, 0, 0, 1);
  }

  /* draw blocks as cubes */
  for (ix=0; ix<ancho; ix++) {
    for (iy=0; iy<alto; iy++) {

      lienzo.pushMatrix();
      lienzo.translate(ix*w, iy*w, 0);
      switch (mapa[int(ix)][int(iy)]) {
      case MAPA_WALL:

        lienzo.fill(128);
        lienzo.box(w);
        break;
      case MAPA_OUTSIDE:
        lienzo.fill(0, 255, 0);
        lienzo.box(w);
        break;
      case MAPA_EXIT:
        lienzo.fill(128, 128, 0);
        lienzo.shape(EXIT);
        break;
      }
      lienzo.popMatrix();
    }
  }
  lienzo.endDraw();
  /* show the canvas */
  image(lienzo, 0, 0);

  /* draw some buttons */

  float w3=width/3;
  float w6=w3/2;
  float h3=200/2;

  stroke(75, 175, 75);
  fill(100, 200, 100);
  rect(0, 800, w3, 200);
  fill(128, 255, 128);
  rect(w3, 800, w3, 200);
  fill(100, 200, 100);
  rect(0, 800, w3, 200);
  rect(2*w3, 800, w3, 200);
  fill(255);
  stroke(0);
  equilatero(w6, 800+h3, 100, PI);
  equilatero(width/2, 800+h3, 100, -HALF_PI);
  equilatero(5*w6, 800+h3, 100, 0);
  textAlign(CENTER);
  text(fdir, width/2, 50);
}

/* draw regular triangle */
void equilatero(float tx, float ty, float radi, float ang) {
  beginShape(TRIANGLE);
  float a;
  a=ang;
  for (int f=0; f<3; f++) {
    vertex(tx+radi*cos(a), 
      ty+radi*sin(a));
    a+=TWO_PI/3;
  }
  endShape();
}

/* detect mousepress / touch */
/* and manage buttons */
void mousePressed() {
  if (mouseY>800) {

    switch (int(3*mouseX/1000)) {
    case 0:
      /* left*/
      fdir+=PI/16;
      if (fdir>TWO_PI) fdir-=TWO_PI;
      printms("<");
      break;
    case 2:
      /* right */
      fdir-=PI/16;
      if (fdir<0) fdir+=TWO_PI;
      printms(">");
      break;
    case 1:
      int ix=round(xx/w+cos(fdir));
      int iy=round(yy/w+sin(fdir));

      printms ("test map["+ix+"]["+iy+"]");
      if ((ix>0) && (iy>0)) {
        if ((ix<ancho) && (iy<alto)) {
          if (mapa[int(ix)][int(iy)]!=-1) {
            printms("advance");
            xx+=w*cos(fdir);
            yy+=w*sin(fdir);
          } else {
            printms("hit wall");
          }
        } else {
          printms("out of upper bounds");
        }
      } else {
        printms("out of lower bounds");
      }
      break;
    };
  }
}

/* Map generator.
 Based on what I recall from
 something I typed from
 a ZX Spectrum magazine back in the
 eighties
 */
int generar() {

  int f;
  /* valid directions*/
  int[] dirValidas={};
  /* current direction*/
  int curDir=-1;

  // if (acabado) return;

  //printms(str(x)+","+str(y));

  /* check valid direction
   (directions within map and
   without a path)
   */
  for (f=0; f<4; f++) {
    if (testValida(int(x+dir[f].x*2), int(y+dir[f].y*2))) {
      //printms("dirvalida="+str(f));
      dirValidas=append(dirValidas, f);
      /* valid, push into array */
    } else {
      //printms("dir no valida="+str(f));
      /* invalid */
    }
  }
  //printms(dirValidas);
  if (dirValidas.length==0) {
    /* no valid direction, go back */
    if (mapa[x][y]>4) {
      /* we are back on first square */
      /* or we hit a map limiter wall */
      /* despite of tests against it */
      printms("acabado o error");
      acabado=true;
    } else {
      /* Going back */
      //printms("back");
      /* 
       How did we come here?
       add 180 degrees to it
       (curDir+2)
       so we go back
       */
      curDir=(mapa[x][y]+2)%4;
      /* always move 2 steps */
      for (f=0; f<2; f++) {
        mapa[x][y]=MAPA_PASILLO;
        x+=dir[curDir].x;
        y+=dir[curDir].y;
        if (mapa[x][y]==MAPA_START) acabado=true;
      }

      /* hemos acabado?*/
      if (mapa[x][y]==MAPA_START) acabado=true;
    }
  } else {
    // Choose a random direction
    // from valid ones.
    //printms("forward to");
    curDir=dirValidas[int(random(dirValidas.length))];
    //printms(curDir);

    /* always move 2 steps */
    for (f=0; f<2; f++) {
      x+=dir[curDir].x;
      y+=dir[curDir].y;
      /* store direction on map
       so we can go back */
      mapa[x][y]=curDir;
    }
  }

  dibujar();

  if (acabado) {
    openExit();
    /* End Text */
    /* just in case we disable 3d view */
    textSize(40);
    fill(255);
    textAlign(CENTER);
    text("Acabado", height/2, width/2);
    textSize(38);
    fill(0);
    text("Acabado", height/2, width/2);

    return curDir;
  } else {
    return -1;
  }
}

/* Is (vx,vy) a valid square
 for new route?
 */
boolean testValida(int vx, int vy) {
  /* 1) test for boundary */
  if (vx<0|vx>=ancho) return false;
  if (vy<0|vy>=alto) return false;
  /* 2) test for used tile (>=0) */
  if (mapa[vx][vy]>=0 ) {
    //printms("["+str(vx)+"]["+str(vy)+"]="+str(mapa[vx][vy]));
    return false;
  } 
  return true;
}

/* draws 2d map at generation time */
void dibujar() {
  int f, g;
  for (f=0; f<alto; f++) {
    for (g=0; g<ancho; g++) {
      switch (mapa[f][g]) {
      case -1: 
        /* free square / wall */
        fill(0);
        break;
      case MAPA_OUTSIDE:
        /* borders*/
        fill(128, 0, 0);
        break;
      case MAPA_PASILLO: 
        /* no way out */
        fill(255);
        break;
      case MAPA_N: /* way N*/
        fill(255, 0, 0);
        break;
      case MAPA_E: /* way E*/
        fill(0, 255, 0);
        break;
      case MAPA_S: /* way S*/
        fill(128, 0, 128);
        break;
      case MAPA_W: /* way W*/
        fill(0, 128, 128);
        break;
      case MAPA_START: /* start/end */
        fill(255, 128, 128);
        break;
      }
      rectMode(CORNER);
      rect(g*w, f*h, w, h);
    }
  }
}
void printms(String A) {
  println(A);
  messages=append(messages, A);
}
void showMessages() {
  int f;
  if (messages.length==0) return;
  if (messages.length>5) {
    messages=subset(messages, messages.length-5, 5);
  }
  textAlign(LEFT);
  fill(0);
  for (f=0; f<messages.length; f++) {
    text(messages[f], 50, f*50);
  }
}

/* Opens an exit from the outside of the map */
void openExit() {
  int dirX=0; 
  int dirY=0;
  int whereY;
  //0: 0; 1= random; 2=ancho-1;
  int whereX=int(random (3));

  switch (whereX) {
    // whereX=0 or 2. from left/right border
  case 2:
    whereX=(ancho-1);
    // do not put break here:
  case 0:
    // Exit should be on an even row.
    whereY=(int(random(2, alto-1))/2)*2;
    dirX=(whereX==0 ? 1: -1);
    break;
  default:
    // whereX=1. from top/bottom.
    // Exit should be on an even column.
    whereX=(int(random(2, ancho-1))/2)*2;
    whereY=((random(50)>=25) ? 0 : alto-1);
    dirY=((whereY==0) ? 1:-1);
  }
  salidaX=whereX;
  salidaY=whereY;
  printms("whereX="+whereX+" whereY="+whereY);
  printms("dirX="+dirX+" dirY="+dirY);
  do {
    if (whereX<0|| whereX>ancho) break;
    if (whereY<0|| whereY>alto) break;
    if (mapa[whereX][whereY]==MAPA_PASILLO) break;
    mapa[whereX][whereY]=MAPA_PASILLO;
    whereX+=dirX;
    whereY+=dirY;
    dibujar();
    printms("whereX="+whereX+" whereY="+whereY);
    printms("dirX="+dirX+" dirY="+dirY);
  } while ( true);
  mapa[salidaX][salidaY]=MAPA_EXIT;
}

/* Makes some shapes for 3d map */
void makeShapes() {
  makeExitSign();
}
