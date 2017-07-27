/**
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 temperature_bars.mp4
 */

boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

String dataFile = "data/instructions.json";
JSONArray jsonData;
int yearCount = 0;

float elapsedMs = 0;
float totalMs = 0;
float frameMs = 0;

float barWidth = 0;
float barHeight = 0;
float barXOffset = 0;
float cellWidth = 0;

PImage light;

color[] gradient = {#4a7ba5, #b466d6, #ff3a3a};

color bgColor = #231f20;
color lightColor = #fce4ff;
float highlightOffset = 0.4;
float barWidthResize = 0.9;

PGraphics bg;
float textPositionY = 610;


void setup() {
  size(3686, 922);
  frameRate(fps);
  smooth();
  noStroke();
  colorMode(RGB, 1.0);

  JSONObject json = loadJSONObject(dataFile);
  jsonData = json.getJSONArray("data");
  yearCount = jsonData.size();
  totalMs = json.getFloat("duration");
  frameMs = (1.0/float(fps)) * 1000;
  
  cellWidth = 1.0 * width / yearCount;
  barWidth = cellWidth * barWidthResize;
  barHeight = 1.0 * height;
  barXOffset = (1.0 * cellWidth - barWidth) * 0.5;
  
  bg = createGraphics(width, height);
}

void draw() {
  background(bgColor);
  
  bg.beginDraw();
  bg.clear();
  bg.noStroke();

  for (int i=jsonData.size()-1; i>=0; i--) {
    JSONObject d = jsonData.getJSONObject(i);
    
    float start = d.getFloat("start");
    float end = d.getFloat("end");
    
    if (elapsedMs >= start) {
      float n = norm(elapsedMs, start, end);
      n = max(n, 0.0);
      n = min(n, 1.0);
      
      color dataColor = getColor(gradient, d.getFloat("norm"));
      color highlight = lerpColor(dataColor, lightColor, 0.25);
      
      color c1;
      color c2;
      
      color c = highlight;
      float alpha = 1.0;
      
      if (n < highlightOffset) {
        alpha = norm(n, 0, highlightOffset);
        
      } else {
        n = norm(n, highlightOffset, 1.0);
        c1 = highlight;
        c2 = dataColor;
        c = lerpColor(c1, c2, n);
      }
      
      n = easeInOutSine(n);
      
      float x = 1.0 * i * cellWidth + barXOffset;
      float y = 0;
      
      //tint(#FFFFFF, 0.5);
      //image(light, x, y);

      bg.fill(c, alpha*255);
      bg.rect(x, y, barWidth, barHeight);
    }
  }
  
  //bg.filter(BLUR, 2);
  bg.endDraw();
  image(bg, 0, 0);
  
  for (int i=jsonData.size()-1; i>=0; i--) {
    JSONObject d = jsonData.getJSONObject(i);
    
    float start = d.getFloat("start");
    float end = d.getFloat("end");
    
    if (elapsedMs >= start) {
      int year = d.getInt("year");
      float n = norm(elapsedMs, start, end);
      n = max(n, 0.0);
      n = min(n, 1.0);
      
      if (i > 0 && year % 5 == 0) {
        float tx = 1.0 * i * cellWidth + 0.5 * cellWidth;
        float ty = textPositionY;
        fill(#ffffff, n);
        textAlign(CENTER, BOTTOM);
        textSize(16);
        text(year, tx, ty);
        textSize(20);
        text(d.getString("label"), tx, ty-20); 
      }
    }
    
  }
  
  //filter(BLUR, 6);

  if (captureFrames) {
    saveFrame(outputMovieFile);
  }

  // increment time
  elapsedMs += frameMs;

  // check if we should exit
  if (elapsedMs >= totalMs) {
    exit();
  }



}

void mousePressed() {
  saveFrame("sample.png");
  exit();
}


color getColor(color[] grad, float amount) {
  int gradLen = grad.length;
  float i = (gradLen-1) * amount;
  float remainder = i % 1;
  color c = grad[0];
  if (remainder > 0) {
    c = lerpColor(grad[int(i)], grad[int(i)+1], remainder);
  } else {
    c = grad[int(i)];
  }
  return c;
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