#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

varying vec2 texCoord;

#define TAPS 6
#define DISTANCE 12

const float angle = radians( 360.0 / float( TAPS ) );
const float angleSin = sin( angle );
const float angleCos = cos( angle );
const mat2 rotationMatrix = mat2( angleCos, angleSin, -angleSin, angleCos );

float ssao( float sourceDepth ) {
  vec2 tapOffset = vec2( 0.0, 1.0 / 512.0 ); // Fixed step for varying resolutions
  float dist = 1.0 - pow( sourceDepth, 64.0 );

  float occlusion = 0.0;
  for ( int ii = 0; ii < TAPS; ++ii ) {
    for ( int jj = 0; jj < DISTANCE; ++jj ) {
      float mul = float( jj + 1 ) * dist;
      float tapValue = texture2D( DiffuseDepthSampler, texCoord + ( tapOffset * mul ) ).r;
      float rangeCheck = clamp( smoothstep( 0.0, 1.0, mul / abs( sourceDepth - tapValue ) ), 0.0, 1.0 );
      occlusion += tapValue >= sourceDepth ? rangeCheck : 0.0;
    }
    tapOffset = rotationMatrix * tapOffset;
  }
  return occlusion / float( TAPS * DISTANCE );
}

vec3 bloom() {
  vec2 tapOffset = vec2( 0.0, 1.0 / 1024.0 ); // Fixed step for varying resolutions
  vec4 color = vec4( 0.0 );
  for ( int ii = 0; ii < TAPS; ++ii ) {
    for ( int jj = 0; jj < DISTANCE; ++jj ) {
      color += texture2D( DiffuseSampler, texCoord + ( tapOffset * float( jj + 1 ) ) );
    }
    tapOffset = rotationMatrix * tapOffset;
  }
  color /= float( TAPS * DISTANCE );
  return color.rgb * 0.125;
}

void main() {
  float depth = texture2D( DiffuseDepthSampler, texCoord ).r;
  vec3 color = texture2D( DiffuseSampler, texCoord ).rgb;

  float ao = 1.0;
  if ( depth < 1.0 ) {
    ao = ssao( depth );
  }

  float shadow = depth < ( 1.0 - 1.0 / 1024.0 ) ? clamp( smoothstep( 0.0, 0.5, ao ), 0.0, 1.0 ) : 1.0;

  gl_FragColor = vec4( mix( color * 0.5, color, shadow ), 1.0 );
  gl_FragDepth = depth;
}
