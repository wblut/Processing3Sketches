#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;
varying vec4 vertTexCoord;
 
void main(void) {
   vec2 p =  vec2(0.5+abs(vertTexCoord.x-0.5),0.5+abs(vertTexCoord.y-0.5));

  gl_FragColor = texture2D(texture, p);
}