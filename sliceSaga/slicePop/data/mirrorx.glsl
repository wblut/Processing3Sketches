#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;
varying vec4 vertTexCoord;
 
void main(void) {
  vec2 p = vertTexCoord.x < 0.5 ? vertTexCoord.xy : vec2(1.0-vertTexCoord.x, vertTexCoord.y);
  gl_FragColor = texture2D(texture, p);
}