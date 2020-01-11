#version 120
/* MakeUp Ultra Fast - gbuffers_clouds.fsh
Render: sky, clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define REFLECTION 1 // [0 1] 0 = Off, 1 = On
#define REFRACTION 1 // [0 1] 0 = Off, 1 = On

#include "/lib/globals.glsl"
#include "/lib/color_utils.glsl"

varying vec2 texcoord;
varying vec4 color;

// 'Global' constants from system
uniform int worldTime;
uniform sampler2D texture;
uniform float wetness;
uniform float far;
uniform vec3 skyColor;

void main() {
	vec4 block_color = texture2D(texture, texcoord.xy) * color;
	gl_FragData[0] = block_color;
  gl_FragData[5] = block_color;
	// gl_FragData[1] = vec4(0.0);  // Not needed. Performance trick

  float current_hour = worldTime / 1000.0;

  float fog_intensity_coeff = mix(
    fog_density[int(floor(current_hour))],
    fog_density[int(ceil(current_hour))],
    fract(current_hour)
    );
  fog_intensity_coeff = max(fog_intensity_coeff, wetness);
  float new_frog = (((gl_FogFragCoord / far) * (2.0 - fog_intensity_coeff)) - (1.0 - fog_intensity_coeff)) * far;
  float frog_adjust = new_frog / far;

  gl_FragData[0].rgb =
    mix(
      gl_FragData[0].rgb,
      gl_Fog.color.rgb,
      pow(clamp(frog_adjust, 0.0, 1.0), 2)
    );
}
