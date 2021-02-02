#version 120

float maxBrighten = 1.3;    //Maximum brightening of the screen (should be greater than 1)
float HDRRatio = 0.6;       //Ajust for stronger or subtler HDR (between 0 and 1)
float idealLum = 0.5;       //The prefered average luminosity of the screen (between 0 and 1)

uniform sampler2D DiffuseSampler;
uniform sampler2D MBSampler;
uniform vec2 OutSize;
varying vec2 texCoord;
varying vec2 oneTexel;

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

    gl_FragColor = toGamma(finalColor);
    
}

/*

    //vec4 x = max(vec4(0.0),outputColor-0.004);
    //vec4 filmicTonemap=(x*(6.2*x+0.5))/(x*(6.2*x+1.7)+0.06);

    vec4 inputHSL = RGBtoHSL(inputColor);
    

    //desaturate dark things
    float brightness = min(0.25,inputHSL.b)*4.0;
    vec4 finalHSL = inputHSL*vec4(1.0,0.5+(brightness*0.5),1.0,1.0);
    vec4 color=HSLtoRGB(finalHSL);

vec4 RGBtoHSL( vec4 col )
{
        float red   = col.r;
        float green = col.g;
        float blue  = col.b;
        float minc  = min(min( col.r, col.g),col.b) ;
        float maxc  = max(max( col.r, col.g),col.b);
        float delta = maxc - minc;
        float lum = (minc + maxc) * 0.5;
        float sat = 0.0;
        float hue = 0.0;
        if (lum > 0.0 && lum < 1.0) {
                float mul = (lum < 0.5)  ?  (lum)  :  (1.0-lum);
                sat = delta / (mul * 2.0);
        }
        vec3 masks = vec3(
                (maxc == red   && maxc != green) ? 1.0 : 0.0,
                (maxc == green && maxc != blue)  ? 1.0 : 0.0,
                (maxc == blue  && maxc != red)   ? 1.0 : 0.0
        );
        vec3 adds = vec3(
                          ((green - blue ) / delta),
                2.0 + ((blue  - red  ) / delta),
                4.0 + ((red   - green) / delta)
        );
        float deltaGtz = (delta > 0.0) ? 1.0 : 0.0;
        hue += dot( adds, masks );
        hue *= deltaGtz;
        hue /= 6.0;
        if (hue < 0.0)
                hue += 1.0;
        return vec4( hue, sat, lum, col.a );
}

vec4 HSLtoRGB( vec4 col )
{
    const float onethird = 1.0 / 3.0;
    const float twothird = 2.0 / 3.0;
    const float rcpsixth = 6.0;

    float hue = col.x;
    float sat = col.y;
    float lum = col.z;

    vec3 xt = vec3(
        rcpsixth * (hue - twothird),
        0.0,
        rcpsixth * (1.0 - hue)
    );

    if (hue < twothird) {
        xt.r = 0.0;
        xt.g = rcpsixth * (twothird - hue);
        xt.b = rcpsixth * (hue      - onethird);
    } 

    if (hue < onethird) {
        xt.r = rcpsixth * (onethird - hue);
        xt.g = rcpsixth * hue;
        xt.b = 0.0;
    }

    xt = min( xt, 1.0 );

    float sat2   =  2.0 * sat;
    float satinv =  1.0 - sat;
    float luminv =  1.0 - lum;
    float lum2m1 = (2.0 * lum) - 1.0;
    vec3  ct     = (sat2 * xt) + satinv;

    vec3 rgb;
    if (lum >= 0.5)
         rgb = (luminv * ct) + lum2m1;
    else rgb =  lum    * ct;

    return vec4( rgb, col.a );
}
*/