/**
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 solar_energy.mp4
 */

boolean captureFrames = false;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

float elapsedMs = 0;
float totalMs = 60000;
float frameMs = 0;

color bgColor = #231f20;

PGraphics gImage;
PGraphics gText;

ArrayList<Circle> circles;
float circleMs;
float pauseMs;
float transitionMs;

void setup() {
  // size(3686, 922, P2D);
  size(1843, 461, P2D);
  frameRate(fps);

  frameMs = (1.0/float(fps)) * 1000;

  gImage = createGraphics(width, height);
  //gText = createGraphics(width, height);
  
  circles = new ArrayList<Circle>();
  
  float circleRadius = height * 0.9 * 0.5;
  float cx = width * 0.5;
  float cy = height * 0.5;
  
  circles.add(new Circle(cx, cy, circleRadius, 1.0, 10000, #ff9d00, "The energy the sun emits"));
  circles.add(new Circle(cx, cy, circleRadius, 0, 10000, #ff9d00, "The sun's energy that strikes Earth"));
  circles.add(new Circle(cx, cy, circleRadius, 0, 1000, #ff9d00, "The energy needed to meet All humanity's energy needs"));
  circles.add(new Circle(cx, cy, circleRadius, 0, 1.0, #ff9d00, "The energy we capture from the sun"));
  
  circleMs = totalMs / (circles.size() + 0.5);
  pauseMs = (circleMs * 3 / 2) / 6;
  transitionMs = ((circleMs * 3 / 2) - pauseMs) * 0.5;

}

void draw() {
  background(bgColor);

  gImage.beginDraw();
  gImage.clear();
  gImage.smooth();
  gImage.strokeWeight(5);
  gImage.ellipseMode(RADIUS);

  //gText.beginDraw();
  //gText.clear();
  //gText.noStroke();
  //gText.smooth();
  //gText.textAlign(LEFT, BOTTOM);
  //gText.textSize(16);
  //gText.endDraw();
  
  for (int i=0; i<circles.size(); i++) {
    Circle c = circles.get(i);
    
    float startMs = i * circleMs;
    float endMs = startMs + pauseMs + transitionMs * 2;
    float radius = 0;
    
    if (elapsedMs >= startMs && elapsedMs < startMs+transitionMs) {
      radius = c.getLerpedRadius(norm(elapsedMs, startMs, startMs+transitionMs), -1);
      
    } else if (elapsedMs >= startMs+transitionMs && elapsedMs < startMs+transitionMs+pauseMs) {
      radius = c.getRadius();
      
    } else if (elapsedMs >= startMs+transitionMs+pauseMs && elapsedMs < endMs) {
      radius = c.getLerpedRadius(norm(elapsedMs, startMs+transitionMs+pauseMs, endMs), 1);
    }
    
    gImage.fill(c.getColor(), 255*0.33);
    
    if (radius < (width*0.5) && radius > 0) {
      gImage.stroke(c.getColor());
      gImage.ellipse(c.getX(), c.getY(), radius, radius);
      
    } else if (elapsedMs > endMs || radius >= (width*0.5)) {
      gImage.noStroke();
      gImage.rect(0, 0, width, height);
    }
  }
  
  gImage.endDraw();

  image(gImage, 0, 0);
  
  //image(gText, 0, 0);

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

class Circle {
  float x, y, radius, multStart, multEnd;
  String label;
  color fillColor;

  Circle(float _x, float _y, float _r, float _multStart, float _multEnd, color _c, String _label) {
    x = _x;
    y = _y;
    radius = _r;
    multStart = _multStart;
    multEnd = _multEnd;
    fillColor = _c;
    label = _label;
  }
  
  color getColor() {
    return fillColor; 
  }
  
  float getLerpedRadius(float p, float d) {
    p = easeInOutCubic(p);
    float r = radius;
    float a = PI * r * r;
    if (d < 0) {
      a = lerp(a*multStart, a, p);
    } else if (d > 0) {
      a = lerp(a, a*multEnd, p);
    }
    r = sqrt(a / PI);
    return r;
  }
  
  float getRadius() {
    return radius;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }

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