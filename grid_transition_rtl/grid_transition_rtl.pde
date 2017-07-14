/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 grid_transition.rtl.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

int gridW = 9;
int gridH = 4;
int grid;
float cellW;
float cellH;

float elapsedMs = 0;
float totalMs = 30000;
float fadeMsMin = 100;
float fadeMsMax = 800;
float fadeMsOffsetMin = 4000;
float fadeMsOffsetMax = 24000;
float frameMs;

void setup() {
  size(3686, 922);
  frameRate(fps);
  smooth();
  noStroke();
  
  frameMs = (1.0/float(fps)) * 1000;
  
  // grids
  grid = gridW * gridH;
  cellW = 1.0 * width / gridW;
  cellH = 1.0 * height / gridH;

}

void draw() {
   // check if we should exit
   if (elapsedMs > totalMs) {
    exit();
   }
   
   background(0);
  
  for (int y = 0; y < gridH; y++) {
    for (int x = 0; x < gridW; x++) {
      int loc = x + y * gridW;
      
      float cellX = cellW * x;
      float cellY = cellH * y;
      
      float gh = halton(loc, 13);
      float gh2 = halton(loc, 5);
      
      float fadeProgress = 0.0;
      float fadeOffset = lerp(fadeMsOffsetMin, fadeMsOffsetMax, gh2);
      fadeOffset = fadeOffset * (float(gridW-x) / gridW);
      if (elapsedMs > fadeOffset) {
        float fadeDuration = lerp(fadeMsMin, fadeMsMax, gh);
        fadeProgress = (elapsedMs - fadeOffset) / fadeDuration;
      }
      
      if (fadeProgress > 1.0) {
        fadeProgress = 1.0;
      }
      
      fill(#FFFFFF, fadeProgress*255);
      rect(cellX, cellY, cellW, cellH);
    }
  }
  
  if (captureFrames) {
    saveFrame(outputMovieFile); 
  }
  
  // increment time
  elapsedMs += frameMs;
  
}

void mousePressed() {
  exit();
}

float halton(int hIndex, int hBase) {    
  float result = 0;
  float f = 1.0 / hBase;
  int i = hIndex;
  while(i > 0) {
    result = result + f * float(i % hBase);
    
    i = floor(i / hBase);
    f = f / float(hBase);
  }
  return result;
}