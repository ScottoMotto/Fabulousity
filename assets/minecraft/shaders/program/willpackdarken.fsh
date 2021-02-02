#version 120

float maxBrighten = 4.6;    //Maximum brightening of the screen (should be greater than 1)
float HDRRatio = 0.6;       //Ajust for stronger or subtler HDR (between 0 and 1)
float idealLum = 0.5;       //The prefered average luminosity of the screen (between 0 and 1)

uniform sampler2D DiffuseSampler;
uniform sampler2D MBSampler;
uniform vec2 OutSize;
varying vec2 texCoord;

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


//samples color from 16 places on the screen and averages them
vec4 averageColor=(
    texture2D(MBSampler, vec2(0.2,0.2))+
    texture2D(MBSampler, vec2(0.2,0.4))+
    texture2D(MBSampler, vec2(0.2,0.6))+
    texture2D(MBSampler, vec2(0.2,0.8))+

    texture2D(MBSampler, vec2(0.4,0.2))+
    texture2D(MBSampler, vec2(0.4,0.4))+
    texture2D(MBSampler, vec2(0.4,0.6))+
    texture2D(MBSampler, vec2(0.4,0.8))+

    texture2D(MBSampler, vec2(0.6,0.2))+
    texture2D(MBSampler, vec2(0.6,0.4))+
    texture2D(MBSampler, vec2(0.6,0.6))+
    texture2D(MBSampler, vec2(0.6,0.8))+

    texture2D(MBSampler, vec2(0.8,0.2))+
    texture2D(MBSampler, vec2(0.8,0.4))+
    texture2D(MBSampler, vec2(0.8,0.6))+
    texture2D(MBSampler, vec2(0.8,0.8))
)/16.0;

float averageLum=toLinear(toLum(averageColor));

void main() {
    vec4 color = toLinear( texture2D(DiffuseSampler, texCoord) );

    float a = (maxBrighten-(1-HDRRatio))/HDRRatio;
    vec4 averagedColor = color*clamp(idealLum/averageLum,1.0,a);
    vec4 finalColor = mix(color,averagedColor,HDRRatio);

    gl_FragColor = (
        toGamma(
            max(finalColor-1.0,0.0)
        )
    )*0.5;
}
