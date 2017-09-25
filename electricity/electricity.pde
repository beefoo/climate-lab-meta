/**
 * Night time globe rotation
 *   Image source: https://www.nasa.gov/feature/goddard/2017/new-night-lights-maps-open-up-possible-real-time-applications
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 electricity.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

float elapsedMs = 0;
float totalMs = 60000;
float frameMs;

float rotation = -180;
float rotationStep = 0.01;
float rotateUp = -25;

float xOffset;
float sphereRadius;
float fov;
float aspectRatio;
float orbitRadius;

int ptsW, ptsH;
PImage img;
int numPointsW;
int numPointsH_2pi; 
int numPointsH;
float[] coorX;
float[] coorY;
float[] coorZ;
float[] multXZ;

PGraphics pg;

void setup() {
  size(3686, 690, P3D);
  background(0);
  noStroke();
  
  pg = createGraphics(width, height, P3D);
  pg.noStroke();
  
  img=loadImage("data/BlackMarble_2016_3km.jpg");
  ptsW=30;
  ptsH=30;
  // Parameters below are the number of vertices around the width and height
  initializeSphere(ptsW, ptsH);
  
  orbitRadius = height * 0.1;
  sphereRadius = orbitRadius * 0.5;
  fov = PI/12.0; 
  aspectRatio = (1.0 * width) / (1.0 * height);
  xOffset = - width * 0.2;
  
  frameMs = (1.0/float(fps)) * 1000;
  
  //noLoop();
}

void draw() {
  background(0);
  
  //print("x: "+mouseX+" y: "+mouseY, 10, 15);
  pg.beginDraw();
  pg.background(0);
  pg.noStroke();
  
  float cy = sin(radians(rotateUp))*orbitRadius;
  float cx = cos(radians(rotation))*orbitRadius;
  float cz = sin(radians(rotation))*orbitRadius;
  
  pg.perspective(fov, aspectRatio, orbitRadius/10.0, orbitRadius*10.0);
  
  pg.camera(cx, cy, cz, // camera position
         0, 0, 0, // looking at
         0, 1, 0); // up
    
  pg.pushMatrix();
  pg.translate(0, 0, 0);  
  textureSphere(sphereRadius, sphereRadius, sphereRadius, img);
  pg.popMatrix();
  

  pg.endDraw();
  image(pg, xOffset, 0);
  
  rotation += rotationStep;
  
  if (captureFrames) {
    saveFrame(outputMovieFile); 
  }
  
  // increment time
  elapsedMs += frameMs;
  
  // check if we should exit
  if (elapsedMs > totalMs) {
    exit();
  }
}

void mousePressed() {
  //print("x: "+mouseX+" y: "+mouseY);
  exit();
}

void initializeSphere(int numPtsW, int numPtsH_2pi) {

  // The number of points around the width and height
  numPointsW=numPtsW+1;
  numPointsH_2pi=numPtsH_2pi;  // How many actual pts around the sphere (not just from top to bottom)
  numPointsH=ceil((float)numPointsH_2pi/2)+1;  // How many pts from top to bottom (abs(....) b/c of the possibility of an odd numPointsH_2pi)

  coorX=new float[numPointsW];   // All the x-coor in a horizontal circle radius 1
  coorY=new float[numPointsH];   // All the y-coor in a vertical circle radius 1
  coorZ=new float[numPointsW];   // All the z-coor in a horizontal circle radius 1
  multXZ=new float[numPointsH];  // The radius of each horizontal circle (that you will multiply with coorX and coorZ)

  for (int i=0; i<numPointsW ;i++) {  // For all the points around the width
    float thetaW=i*2*PI/(numPointsW-1);
    coorX[i]=sin(thetaW);
    coorZ[i]=cos(thetaW);
  }
  
  for (int i=0; i<numPointsH; i++) {  // For all points from top to bottom
    if (int(numPointsH_2pi/2) != (float)numPointsH_2pi/2 && i==numPointsH-1) {  // If the numPointsH_2pi is odd and it is at the last pt
      float thetaH=(i-1)*2*PI/(numPointsH_2pi);
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=0;
    } 
    else {
      //The numPointsH_2pi and 2 below allows there to be a flat bottom if the numPointsH is odd
      float thetaH=i*2*PI/(numPointsH_2pi);

      //PI+ below makes the top always the point instead of the bottom.
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=sin(thetaH);
    }
  }
}

void textureSphere(float rx, float ry, float rz, PImage t) { 
  // These are so we can map certain parts of the image on to the shape 
  float changeU=t.width/(float)(numPointsW-1); 
  float changeV=t.height/(float)(numPointsH-1); 
  float u=0;  // Width variable for the texture
  float v=0;  // Height variable for the texture

  pg.beginShape(TRIANGLE_STRIP);
  pg.texture(t);
  for (int i=0; i<(numPointsH-1); i++) {  // For all the rings but top and bottom
    // Goes into the array here instead of loop to save time
    float coory=coorY[i];
    float cooryPlus=coorY[i+1];

    float multxz=multXZ[i];
    float multxzPlus=multXZ[i+1];

    for (int j=0; j<numPointsW; j++) { // For all the pts in the ring
      pg.normal(-coorX[j]*multxz, -coory, -coorZ[j]*multxz);
      pg.vertex(coorX[j]*multxz*rx, coory*ry, coorZ[j]*multxz*rz, u, v);
      pg.normal(-coorX[j]*multxzPlus, -cooryPlus, -coorZ[j]*multxzPlus);
      pg.vertex(coorX[j]*multxzPlus*rx, cooryPlus*ry, coorZ[j]*multxzPlus*rz, u, v+changeV);
      u+=changeU;
    }
    v+=changeV;
    u=0;
  }
  pg.endShape();
}