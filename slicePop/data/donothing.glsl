#define PROCESSING_TEXTURE_SHADER
 
uniform sampler2D texture;
varying vec4 vertTexCoord;
 
void main(void) {

  gl_FragColor = texture2D(texture, vertTexCoord.xy);
}