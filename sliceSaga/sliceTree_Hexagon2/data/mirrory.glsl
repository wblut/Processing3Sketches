#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;
varying vec4 vertTexCoord;
 
void main(void) {
  vec2 p = vertTexCoord.y > 0.5 ? vertTexCoord.xy : vec2(vertTexCoord.x, 1.0-vertTexCoord.y);
  gl_FragColor = texture2D(texture, p);
}