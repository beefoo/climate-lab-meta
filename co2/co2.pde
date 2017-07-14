/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 co2.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

float elapsedMs = 0;
float totalMs = 30000;
float emissionMsStart = 2000;
float emissionMsEnd = 6000;
float frameMs;

ArrayList<ParticleSystem> ps;
float particleRadius = 4;

void setup() {
  size(3686, 922);
  frameRate(fps);
  smooth();
  noStroke();
  colorMode(HSB, 1.0);
   
  float psWidth = width / 3.0;
  float psHeight = height * 0.75;
  float psX = 0.0;
  float psY = 0.0;
  
  float emissionsFrames = fps * ((emissionMsEnd-emissionMsStart)/1000);
  
  ps = new ArrayList<ParticleSystem>();
  // fossil fuel emissions (million metric tons of carbon) in 1900, 1950, 2014
  ps.add(new ParticleSystem(particleRadius, "1900", 534, psX, psY, psWidth, psHeight, #dae6e6, emissionsFrames));
  ps.add(new ParticleSystem(particleRadius, "1950", 1630, psX + psWidth, psY, psWidth, psHeight, #3fc1be, emissionsFrames));
  ps.add(new ParticleSystem(particleRadius, "2014", 9855, psX + psWidth*2, psY, psWidth, psHeight, #f1a051, emissionsFrames));
  
  frameMs = (1.0/float(fps)) * 1000;

}

void draw() {
  // check if we should exit
  if (elapsedMs > totalMs) {
    exit();
  }
   
  background(0);
  
  float ePercent = norm(elapsedMs, emissionMsStart, emissionMsEnd);
  
  if (ePercent >= 0.0) {
    for(ParticleSystem p : ps) {
      p.run();
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

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  float radius;
  int count, current, perFrame;
  float x, y, w, h;
  String label;
  color pColor;

  ParticleSystem(float _radius, String _label, int _count, float _x, float _y, float _w, float _h, color _c, float _frames) {
    particles = new ArrayList<Particle>();
    radius = _radius;
    label = _label;
    count = _count;
    current = 0;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    pColor = _c;
    perFrame = round(float(_count) / _frames);
  }

  void addParticle() {
    particles.add(new Particle(x, y, w, h, radius, pColor));
  }

  void run() {
    // add new particles
    if (current < count) {
      int newCount = min(count, current+perFrame);
      int addCount = newCount - current;
      current = newCount;
      for (int i=0; i<addCount; i++) {
        addParticle();
      }
    }
    
    
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
    }
  }
}


// A simple Particle class

class Particle {
  PVector acceleration;
  PVector position;
  PVector velocity;
  float x, y, w, h;
  float radius;
  float life;
  color pColor;

  Particle(float _x, float _y, float _w, float _h, float rad, color _c) {
    radius = rad;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    life = 0;
    pColor = _c;
    
    float v = 1.0;
    float rw = w * 0.9;
    
    position = new PVector(x+w*0.5+random(-rw/2,rw/2), y+h);
    velocity = new PVector(random(-v,v), random(-v, 0));
    acceleration = new PVector(0.9995, 0.9995);
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    float vx = velocity.x;
    float vy = velocity.y;
    
    float left = x + radius/2;
    float top = y + radius/2;
    float right = x + w - radius/2;
    float bottom = y + h - radius/2;

    position.add(velocity);
    
    // check for left bounds
    if (position.x < left) {
      position.x = left;
      velocity.x = -vx;
      
    // check for right bounds
    } else if (position.x > right) {
      position.x = right;
      velocity.x = -vx;
    }
    
    // check for top bounds
    if (position.y < top) {
      position.y = top;
      velocity.y = -vy;
    
    // check for bottom bounds
    } else if (position.y > bottom) {
      position.y = bottom;
      velocity.y = -vy;
    }
    
    // decelerate
    velocity.x *= acceleration.x;
    velocity.y *= acceleration.y;
    
    if (life < 255) {
      life += 0.01; 
    }
  }

  // Method to display
  void display() {
    fill(pColor, life);
    ellipse(position.x, position.y, radius, radius);
  }
}