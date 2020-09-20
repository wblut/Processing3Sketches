#define PROCESSING_TEXTURE_SHADER

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution; 
varying vec4 vertColor;
varying vec4 vertTexCoord;
 
const float RADIUS = 0.75;
const float SOFTNESS = 0.45;
const vec3 SEPIA = vec3(1.0, 0.8, 0.6); 


void main(void) {
    vec4 texColor = texture2D(texture,vertTexCoord.xy);
    vec2 position = (gl_FragCoord.xy / resolution.xy) - vec2(0.5);
    float len = length(position);
    float vignette = smoothstep(RADIUS, RADIUS-SOFTNESS, len);
    texColor.rgb = mix(texColor.rgb, texColor.rgb * vignette, 0.5);
    float gray = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 sepiaColor = vec3(gray) * SEPIA;
    texColor.rgb = mix(texColor.rgb, sepiaColor, 0.1);
    gl_FragColor = texColor * vertColor;
}