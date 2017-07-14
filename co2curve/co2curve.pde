/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 co2curve.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

String dataFile = "data/processed.json";
JSONArray jsonFrames;
int jsonFrameCount;
int currentJsonFrame = 0;
float circleW = 15;
float margin = 40;

void setup() {
  size(3686, 692);
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
  
  float progress = 1.0 * currentJsonFrame / (jsonFrameCount-1);
  float eased = easeInOutSine(progress);
  int index = round(eased * (jsonFrameCount-1));
  
  JSONArray frameData = jsonFrames.getJSONArray(index);
  float canvasW = 1.0 * width - margin*2;
  float canvasH = 1.0 * height - margin*2;
  
  for (int i = 0; i < frameData.size(); i++) {
    JSONArray point = frameData.getJSONArray(i);
    
    float x = point.getFloat(0) * canvasW + margin;
    float y = 1.0 * height - point.getFloat(1) * canvasH - margin;
    
    float opacity = 1.0 * i / (frameData.size()-1);
    
    if (i==frameData.size()-1) {
      fill(#fff0e1); 
      ellipse(x,y,circleW*2, circleW*2);
    } else {
      fill(#f1a051, opacity);
      ellipse(x,y,circleW, circleW);
    }
    
    //print("("+x+","+y+")");
    
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