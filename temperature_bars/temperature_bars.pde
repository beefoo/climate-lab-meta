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
float barXOffset = 0;
float cellWidth = 0;

PImage light;

color[] gradient = {#4a7ba5, #b466d6, #ff3a3a};

color bgColor = #231f20;
color lightColor = #fce4ff;
float highlightOffset = 0.4;
float barWidthResize = 0.9;

PGraphics dg;
PGraphics hg;
PGraphics tg;
PGraphics ag;
PGraphics cg;

float textPositionY = 0.68;
float border = 0.6844;
int rangeMin = 0;
int rangeMax = 0;
float scaleHighlight = 1.5;

float cw;
float ch;
float marginX = 0.01;

PGraphics gg;
int gradientHeight = 0;

void setup() {
  size(3686, 922, P2D);
  // size(1843, 461, P2D);
  frameRate(fps);

  JSONObject json = loadJSONObject(dataFile);
  jsonData = json.getJSONArray("data");
  yearCount = jsonData.size();
  totalMs = json.getFloat("duration");
  frameMs = (1.0/float(fps)) * 1000;
  
  JSONArray range = json.getJSONArray("range");
  rangeMin = range.getInt(0);
  rangeMax = range.getInt(1);
  
  marginX = marginX * width;
  cw = width - marginX * 2;
  cellWidth = 1.0 * cw / yearCount;
  barWidth = cellWidth * barWidthResize;
  barXOffset = (1.0 * cellWidth - barWidth) * 0.5;
  
  dg = createGraphics(width, height);
  hg = createGraphics(width, height);
  tg = createGraphics(width, height);
  ag = createGraphics(width, height);
  cg = createGraphics(width, height);
  
  // make gradient
  gradientHeight = int(0.05 * height);
  gg = createGraphics(width, gradientHeight);
  gg.beginDraw();
  gg.noFill();
  gg.smooth();
  for (int i = 0; i < gradientHeight; i++) {
    float progress = 1.0 * i / (gradientHeight-1);
    gg.stroke(bgColor, progress * 255);
    gg.line(0, i, width, i);
  }
  gg.endDraw();
  
}

void draw() {
  background(bgColor);
  
  dg.beginDraw();
  dg.clear();
  dg.noStroke();
  dg.smooth();
  
  hg.beginDraw();
  hg.clear();
  hg.noStroke();
  hg.smooth();
  
  tg.beginDraw();
  tg.clear();
  tg.noStroke();
  tg.smooth();
  
  ag.beginDraw();
  ag.clear();
  ag.noStroke();
  ag.smooth();
  
  //cg.beginDraw();
  //cg.clear();
  //cg.noStroke();
  //cg.smooth();
  //cg.tint(255, 60);
  
  int latest = 0;
  
  int latestI = floor(elapsedMs / totalMs * (jsonData.size()-1)) + 1;
  latestI = min(latestI, jsonData.size()-1);
  JSONObject latestYearObj = jsonData.getJSONObject(latestI);
  int latestYear = latestYearObj.getInt("year");
  
  JSONObject coldestYearDisplay = jsonData.getJSONObject(1930-jsonData.getJSONObject(0).getInt("year"));
  JSONObject hottestYearDisplay = jsonData.getJSONObject(2000-jsonData.getJSONObject(0).getInt("year"));

  for (int i=0; i<jsonData.size(); i++) {
    JSONObject d = jsonData.getJSONObject(i);
    
    float start = d.getFloat("start");
    float end = d.getFloat("end");
    int year = d.getInt("year");
    
    if (elapsedMs >= start) {
      float n = norm(elapsedMs, start, end);
      float nn = norm(elapsedMs, start, end + (end-start)*2);
      n = max(n, 0.0);
      n = min(n, 1.0);
      nn = max(nn, 0.0);
      nn = min(nn, 1.0);
      
      color dataColor = getColor(gradient, d.getFloat("norm"));
      color highlight = lerpColor(dataColor, lightColor, 0.25);
      color c1;
      color c2;
      
      color c = highlight;
      float alpha = 1.0;
      
      if (n < highlightOffset) {
        alpha = norm(n, 0, highlightOffset);
        
      } else {
        float nnn = norm(n, highlightOffset, 1.0);
        nnn = easeInOutSine(nnn);
        c1 = highlight;
        c2 = dataColor;
        c = lerpColor(c1, c2, nnn);
      }
      
      float nh = easeInElastic(n);
      float barHeight = d.getFloat("height") * height * nh;
      float x = 1.0 * i * cellWidth + barXOffset + marginX;
      float y = height - barHeight;
      
      //tint(#FFFFFF, 0.5);
      //image(light, x, y);

      dg.noStroke();
      
      //int record = d.getInt("record");
      //if (record > 0) {
        
      //  // draw ghost highlight
      //  float hn = min(n * 2, 1);
      //  float hw = lerp(barWidth, barWidth*scaleHighlight, hn);
      //  float hh = lerp(barHeight, barHeight*scaleHighlight, hn);
      //  float hx = x - (hw - barWidth) * 0.5;
      //  float hy = y - (hh - barHeight) * 0.5;
        
      //  hg.noFill();
      //  hg.strokeWeight(2);
      //  hg.stroke(#ffffff, (1.0-hn)*255);
      //  hg.rect(hx+2, hy, hw-4, hh);
        
      //  hg.noStroke();
      //  hg.fill(#ffffff, (1.0-nn)*255);
      //  hg.textAlign(CENTER, BOTTOM);
      //  hg.textSize(20);
      //  hg.text("Record", hx + hw * 0.5, y - height*0.02);
        
      //  color rc = lerpColor(#ffffff, #ffe8e8, min(n * 2, 1));
      //  dg.stroke(rc);
      //  dg.strokeWeight(2);
      //}
      
      float bw = barWidth;
      float bh = barHeight;
      float bx = x;
      float by = y;
      
      int hottest = d.getInt("hottest");
      
      if (latestYear >= hottestYearDisplay.getInt("year") && hottest > 0) {
        color rc = #fff2f2;
        float _a = norm(elapsedMs, hottestYearDisplay.getFloat("start"), hottestYearDisplay.getFloat("end"));
        _a = min(_a, 1);
        rc = lerpColor(c, rc, _a);
        dg.stroke(rc);
        dg.strokeWeight(3);
        bw -= 4;
        bx += 2;
        //cg.stroke(rc);
        //cg.strokeWeight(2);
        //cg.fill(c, alpha*255);
        //cg.rect(x, y, barWidth, barHeight);
      }
      
      int coldest = d.getInt("coldest");
      
      if (latestYear >= coldestYearDisplay.getInt("year") && coldest > 0) {
        color rc = #f4fbff;
        float _a = norm(elapsedMs, coldestYearDisplay.getFloat("start"), coldestYearDisplay.getFloat("end"));
        _a = min(_a, 1);
        rc = lerpColor(c, rc, _a);
        dg.stroke(rc);
        dg.strokeWeight(3);
        bw -= 4;
        bx += 2;
        //cg.stroke(rc);
        //cg.strokeWeight(2);
        //cg.fill(c, alpha*255);
        //cg.rect(x, y, barWidth, barHeight);
      }
      
      dg.fill(c, alpha*255);
      dg.rect(bx, by, bw, bh);
      
      
      if (year % 10 == 0) {
        float tx = 1.0 * i * cellWidth + 0.5 * cellWidth + marginX;
        float ty = textPositionY * height;
        tg.fill(#ffffff, n*255);
        tg.textAlign(CENTER, BOTTOM);
        tg.textSize(24);
        tg.text(year, tx, ty);
      }
      
      latest = i;
      
    }
  }
  
  // draw axes
  float progress = elapsedMs / totalMs;
  float aw = progress * cw + marginX;
  ag.stroke(#444444);
  ag.strokeWeight(2);
  ag.textAlign(LEFT, BOTTOM);
  ag.textSize(24);
  
  for (int i = rangeMin+1; i < rangeMax; i++) {
    float y = 1.0 - norm(i*1.0, rangeMin*1.0, rangeMax*1.0);
    y = y * height;
    ag.line(0, y, aw, y);
    
    for (int j=0; j<jsonData.size(); j++) {
      JSONObject d = jsonData.getJSONObject(j);
      
      float start = d.getFloat("start");
      float end = d.getFloat("end");
      
      if (elapsedMs >= start) {
        float n = norm(elapsedMs, start, end + (end-start)*2);
        n = max(n, 0.0);
        n = min(n, 1.0);
        int year = d.getInt("year");
        
        if (year % 40 == 0) {
          float tx = 1.0 * j * cellWidth + marginX;
          ag.fill(#DDDDDD, n*255);
          ag.text(i+"°F", tx, y - height * 0.01);
        }
      }
    
    }
  }
  
  
  //cg.filter(BLUR, 4);
  
  dg.endDraw();
  hg.endDraw();
  tg.endDraw();
  ag.endDraw();
  //cg.endDraw();
  
  int gy = height - gradientHeight - int(height - border*height);
  
  image(ag, 0, 0);
  image(dg, 0, 0);
  image(hg, 0, 0);
  image(gg, 0, gy);
  image(tg, 0, 0);
  //image(cg, 0, 0);
  
  
  fill(bgColor);
  noStroke();
  rect(0, border*height, width, int(height - border*height));
  
  //stroke(#ff0000);
  //strokeWeight(2);
  //float by = border * height;
  //line(0, by, width, by);

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

float easeInElastic(float t) {
  float amt = 0.005; // bigger = more bounce
  return (amt - amt / t) * sin(25.0 * t) + 1;
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