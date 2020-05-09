precision mediump float;

uniform sampler2D matcap;
varying vec3 eyeNormal;

uniform float range=1.1;
void main() {
 vec2 uv = range*0.5*vec2(normalize(eyeNormal).xy)+vec2(0.5);
 gl_FragColor = gl_FrontFacing ?texture2D(matcap,vec2(uv.x,1.0-uv.y)):texture2D(matcap,vec2(1.0-uv.x,uv.y));   
}
