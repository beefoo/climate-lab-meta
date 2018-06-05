varying vec2 vUv;
attribute vec2 uv;
attribute vec2 position;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

void main() {
	vUv = uv;
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0, 1.0 );
}
