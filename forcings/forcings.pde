/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 forcings.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "mask/frames-#####.png";
int fps = 30;

String dataFile = "data/instructions.json";
JSONArray jsonFrames;
JSONArray jsonRef;
int jsonFrameCount;
int currentJsonFrame = 0;

void setup() {
  size(1280, 720);
  frameRate(fps);
  smooth();
  noStroke();
  colorMode(HSB, 1.0);
   
  JSONObject json = loadJSONObject(dataFile);
  jsonFrames = json.getJSONArray("frames");
  jsonFrameCount = jsonFrames.size();
  jsonRef = json.getJSONArray("ref");
}

void draw() {
  background(0);
  noFill();
  
  stroke(#ffffff);
  //stroke(#6d6f71);
  strokeWeight(12);
  beginShape();
  for (int i = 0; i < jsonRef.size(); i++) {
    float x = 1.0 * i / (jsonRef.size()-1) * width;
    float y = 1.0 * height - jsonRef.getFloat(i) * height;
    vertex(x, y);
  }
  endShape();
  
  JSONArray frameData = jsonFrames.getJSONArray(currentJsonFrame);
  //stroke(#f1a051);
  strokeWeight(16);
  beginShape();
  for (int i = 0; i < frameData.size(); i++) {
    float x = 1.0 * i / (frameData.size()-1) * width;
    float y = 1.0 * height - frameData.getFloat(i) * height;
    vertex(x, y);
  }
  endShape();
  
  if (captureFrames) {
    saveFrame(outputMovieFile); 
  }
  
  currentJsonFrame += 1;
  
  // check if we should exit
  if (currentJsonFrame >= jsonFrameCount) {
    exit();
  }
  
  
  
}

void mousePressed() {
  exit();
}