/**
 * A grid transition mask
 *   To compile: ffmpeg -framerate 30/1 -i frames/frames-%05d.png -c:v libx264 -r 30 -pix_fmt yuv420p -q:v 1 co2b.mp4
 */
 
boolean captureFrames = true;
String outputMovieFile = "frames/frames-#####.png";
int fps = 30;

float elapsedMs = 0;
float totalMs = 30000;
float emissionMsStart = 0;
float emissionMsEnd = 25000;
float frameMs;

ParticleSystem ps;
float particleRadius;

Table data;
String year;

void setup() {
  size(3686, 922, P2D);
  //size(1843, 461, P2D);
  //size(1920, 480, P2D);
  frameRate(fps);
  smooth();
  noStroke();
  //lights();
  colorMode(HSB, 1.0);
   
  float psWidth = width;
  float psHeight = height * 0.75;
  float psX = 0.0;
  float psY = 0.0;
  
  particleRadius = width / 460.0;
  data = loadTable("global.1751_2014.csv", "header");
  
  ps = new ParticleSystem(particleRadius, psX, psY, psWidth, psHeight, #dae6e6);
  
  frameMs = (1.0/float(fps)) * 1000;
  year = "";

}

void draw() {
  // check if we should exit
  if (elapsedMs > totalMs) {
    exit();
  }
   
  background(0);
  
  float ePercent = norm(elapsedMs, emissionMsStart, emissionMsEnd);
  
  if (ePercent >= 0.0 && ePercent <= 1.0) {
    int currentCount = ps.getCount();
    int index = round(ePercent * (data.getRowCount()-1));
    TableRow row = data.getRow(index);
    int total = row.getInt("total");
    year = row.getString("year");
    if (total > currentCount) {
      ps.addParticles(total - currentCount); 
    }
  }
  
  ps.run();
  
  fill(#ffca59);
  textAlign(CENTER, CENTER);
  textSize(width / 75.0);
  text(year, width / 9.0 - width / 18.0, height * (5.0/8.0));
  text(year, width - width / 9.0 + width / 18.0, height * (5.0/8.0));
  
  //fill(#ffca59);
  //text("Fossil fuel carbon emissions", width / 2.0, height * 0.75 * 0.5 - height * 0.04);
  //textSize(width / 80.0);
  //text("Millions of metric tons of carbon", width / 2.0, height * 0.75 * 0.5 + height * 0.04);
  
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
  int count, current;
  float x, y, w, h;
  color pColor;

  ParticleSystem(float _radius, float _x, float _y, float _w, float _h, color _c) {
    particles = new ArrayList<Particle>();
    radius = _radius;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    pColor = _c;
  }

  void addParticles(int amount) {
    for (int i=0; i<amount; i++) {
      particles.add(new Particle(x, y, w, h, radius, pColor));
    }
  }
  
  int getCount(){
    return particles.size();
  }

  void run() {
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
  float maxAlpha;

  Particle(float _x, float _y, float _w, float _h, float rad, color _c) {
    radius = rad;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    life = 0;
    pColor = _c;
    maxAlpha = 0.5;
    
    float v = 1.0;
    float rw = w * 0.95;
    float rh = h * 0.95;
    
    position = new PVector(x+w*0.5+random(-rw/2,rw/2), y+h*0.5+random(-rh/2,rh/2), (radius/2) * random(0,1) + radius/2);
    velocity = new PVector(random(-v,v), random(-v, v), random(-radius/100,radius/100));
    acceleration = new PVector(0.9995, 0.9995, 0.9995);
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    float vx = velocity.x;
    float vy = velocity.y;
    float vz = velocity.z;
    
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
    
    // check for z bounds
    if (position.z < radius/2) {
      position.z = radius/2;
      velocity.z = -vz;
      
    } else if (position.z > radius) {
      position.z = radius;
      velocity.z = -vz;
    }
    
    // decelerate
    velocity.x *= acceleration.x;
    velocity.y *= acceleration.y;
    velocity.z *= acceleration.z;
    
    if (life < maxAlpha) {
      life += 0.01; 
    }
  }

  // Method to display
  void display() {
    fill(pColor, life);
    ellipse(position.x, position.y, position.z, position.z);
    //pushMatrix();
    //translate(position.x, position.y, position.z);
    //sphere(radius);
    //popMatrix();
  }
}