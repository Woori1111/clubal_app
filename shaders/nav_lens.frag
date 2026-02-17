#include <flutter/runtime_effect.glsl>

// Auto-populated by ImageFilter.shader:
uniform vec2 u_size;
uniform sampler2D u_texture;
// Custom uniforms set from Dart:
uniform float u_maxScale;
uniform float u_exponent;

out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 c = u_size * 0.5;
  vec2 d = p - c;
  float radius = min(u_size.x, u_size.y) * 0.5;
  float r = clamp(length(d) / radius, 0.0, 1.0);

  // Center=1x, edge approaches u_maxScale with exponential ramp.
  float scale = 1.0 + (u_maxScale - 1.0) * pow(r, u_exponent);
  vec2 samplePos = c + (d / scale);
  vec2 uv = samplePos / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  fragColor = texture(u_texture, uv);
}
