PShader shade;

void setup() {
  size(640, 360, P2D);
  smooth();
  
  shade = loadShader("glowfrag.glsl", "glowvert.glsl"); 
}

void draw() {
  background(#222222);
  stroke(#eeeeee);
  strokeWeight(5);
  fill(#ffe100);
  
  shader(shade); 
  
  pushMatrix();
  translate(width*0.2, height*0.5);
  rotate(frameCount / 200.0);
  polygon(0, 0, 82, 3);  // Triangle
  popMatrix();
  
  pushMatrix();
  translate(width*0.5, height*0.5);
  rotate(frameCount / 50.0);
  polygon(0, 0, 80, 20);  // Icosahedron
  popMatrix();
  
  pushMatrix();
  translate(width*0.8, height*0.5);
  rotate(frameCount / -100.0);
  polygon(0, 0, 70, 7);  // Heptagon
  popMatrix();
}

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}