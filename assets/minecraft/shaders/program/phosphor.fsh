#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D PrevSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

uniform vec2 InSize;

uniform vec3 Phosphor = vec3(0.7, 0.7, 0.7);
uniform float LerpFactor = 1.0;

float toLum (vec4 color){
    return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
}

vec4 toLinear (vec4 color){
    return pow(color,vec4(2.2));
}

float toLinear (float value){
    return pow(value,2.2);
}

vec4 toGamma (vec4 color){
    return pow(color,vec4(1.0/2.2));
}

float toGamma (float value){
    return pow(value,1.0/2.2);
}

void main() {
    vec4 CurrColor = toLinear(texture2D(DiffuseSampler, texCoord));
    vec4 PrevColor = toLinear(texture2D(PrevSampler, texCoord));


    vec4 FinalColor = mix(PrevColor,CurrColor,0.02);
    
    gl_FragColor = toGamma(FinalColor);
}




/*

vec4 pack (float a){
    a*=(256*256*256);
    float r=a/(256*256);
    float g=a-int(r*256*256)/256;
    float b=a-(int(r*256*256)+int(g*256));
    return vec4(
         r/256.0
        ,g/256.0
        ,b/256.0
    ,1.0);
}

float unpack (vec4 a){
    return (256*256*a.r+256*a.g+a.b)/(256*256);
}

*/