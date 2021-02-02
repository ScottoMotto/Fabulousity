#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

void main() {
  float dist = pow( length( distance( texCoord.x, 0.5 ) ), 2.5 ) * 16.0;

  vec4 rValue = texture2D( DiffuseSampler, texCoord + vec2( oneTexel.x * dist, 0.0 ) );
  vec4 gValue = texture2D( DiffuseSampler, texCoord );
  vec4 bValue = texture2D( DiffuseSampler, texCoord - vec2( oneTexel.x * dist, 0.0 ) );

  gl_FragColor = vec4( rValue.r, gValue.g, bValue.b, 1.0 );
}
