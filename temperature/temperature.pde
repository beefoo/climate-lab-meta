/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 temperature.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

String dataFile = "data/instructions.json";
JSONArray jsonFrames;
int jsonFrameCount;
int currentJsonFrame = 0;
float circleW = 20;

void setup() {
  size(1280, 720);
  frameRate(fps);
  smooth();
  noStroke();
  colorMode(HSB, 1.0);
   
  JSONObject json = loadJSONObject(dataFile);
  jsonFrames = json.getJSONArray("frames");
  jsonFrameCount = jsonFrames.size();
}

void draw() {
  background(0);
  fill(#dae6e6);
  
  float progress = 1.0 * currentJsonFrame / (jsonFrameCount-1);
  float eased = easeInOutSine(progress);
  int index = round(eased * (jsonFrameCount-1));
  
  JSONArray frameData = jsonFrames.getJSONArray(index);
  float canvasW = 1.0 * width - circleW;
  float canvasH = 1.0 * height - circleW;
  
  for (int i = 0; i < frameData.size(); i++) {
    JSONArray point = frameData.getJSONArray(i);
    
    float x = point.getFloat(0) * canvasW + circleW / 2;
    float y = 1.0 * height - point.getFloat(1) * canvasH + circleW / 2;
    
    ellipse(x,y,circleW, circleW);
  }
  
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


float easeInOutCubic(float t) {
  if (t < 0.5) {
    return 4*t*t*t;
  } else {
    return (t-1)*(2*t-2)*(2*t-2)+1;
  }
};

float easeInOutSine(float t) {
  return (1 + sin(PI * t - PI / 2.0)) / 2.0; 
}