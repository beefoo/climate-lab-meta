#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D tBase;
uniform sampler2D tAdd;
uniform float amount;

varying vec2 vUv;

void main() {
	vec4 texel1 = texture2D( tBase, vUv );
	vec4 texel2 = texture2D( tAdd, vUv );
	gl_FragColor = texel1 + texel2 * amount;
}
