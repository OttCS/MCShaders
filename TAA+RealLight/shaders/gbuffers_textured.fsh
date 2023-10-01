#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

//Diffuse (color) texture.
uniform sampler2D texture;
//Lighting from day/night + shadows + light sources.
uniform sampler2D lightmap;

//RGB/intensity for hurt entities and flashing creepers.
uniform vec4 entityColor;

//Fog mode
uniform int fogMode;
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;
//Diffuse and lightmap texture coordinates.
varying vec2 coord0;
varying vec2 coord1;

float root7(float x) {
    return 0.271828182846 * log2(x) + 1;
}

vec3 mix3(vec3 a, vec3 b, vec3 c, float x, float midpoint) {
    if (x <= midpoint) {
        return mix(a, b, smoothstep(0, midpoint, x));
    } else {
        return mix(b, c, smoothstep(midpoint, 1.0, x));
    }
}

vec4 mix3(vec4 a, vec4 b, vec4 c, float x, float midpoint) {
    if (x <= midpoint) {
        return mix(a, b, smoothstep(0, midpoint, x));
    } else {
        return mix(b, c, smoothstep(midpoint, 1.0, x));
    }
}

uniform int worldTime;

const vec4 Purkinje  = vec4(0.0, 0.6627, 1.0, 0.411559713784);
const vec4 noonlight = vec4(1.0, 254.0 / 255.0, 250.0 / 255.0, 1.0); // Noon sun
const vec4 moonlight = vec4(1.0, 208.0 / 255.0, 171.0 / 255.0, 0.225878276314); // Moonlight
const vec4 riselight = vec4(1.0, 254.0 / 255.0, 250.0 / 255.0, 0.631385035559); // Sun rise/set
const vec4 cliplight = vec4(1.0, 1.0, 1.0, 0.719685673001);

const vec4 BLOCK = vec4(255.0 / 255.0, 177.0 / 255.0, 110.0 / 255.0, 0.651836344869); // Block, 3000K

vec4 SKY = mix3(
    moonlight,
    riselight,
    noonlight,
    clamp(2.421 * (sin(worldTime * 3.14159265358979323 / 12000.0) + 0.42341), 0.0, 1.0), // Time of day
    0.5 // Default threshold
);

// Eye Brightness
uniform ivec2 eyeBrightnessSmooth;

vec4 blockLight (float level) {
    return vec4(BLOCK.rgb, BLOCK.a * level);
}

vec4 skyLight (float level) {
    return vec4(SKY.rgb, SKY.a * level);
}

vec4 addLight(vec4 a, vec4 b) {
    return vec4(max(a.rgb, b.rgb), a.a + b.a);
}

vec4 eyeLight = addLight(
    blockLight(eyeBrightnessSmooth.x / 240.0),
    skyLight(eyeBrightnessSmooth.y / 240.0)
);

vec3 getColor(vec4 a) {
    return a.rgb * pow(min(a.a, 1.0), 7.0);
}

vec4 bake(vec4 base, vec4 light) {
    vec4 result = base.rgba;
    result.rgb *= light.rgb * pow(min(light.a, 1.0), 7.0);
    // result.rgb += max(0.0, pow(light.a - 1.0, 7.0)) * light.rgb;
    return result;
}

// float hspBrightness(vec3 c) {
//     return sqrt( .299 * c.r * c.r + .587 *c.g * c.g + .114 * c.b * c.b );
// }

void main()
{
    // vec3 light = texture2D(lightmap, coord1).rgb; // Normal - Don't use it's bad
    vec4 bl = blockLight(coord1.x);
    vec4 sl = skyLight(coord1.y);

    vec4 light = addLight(bl, sl);
    light.rgb *= mix(Purkinje.rgb, vec3(1.0), smoothstep(0.0, Purkinje.a, light.a));
    
    // vec4 col = color * texture2D(texture, coord0) * vec4(getColor(light), 1.0);
    vec4 col = bake(color * texture2D(texture, coord0), light);
    // col.rgb /= pow(clamp(0.5, 1.0, eyeLight.a), 7.0);
    // if (eyeLight)
    // col.rgb = vec3(pow(light.a, 7.0), 0.0, 0.0); // Debug color

    //Apply entity flashes.
    col.rgb = mix(col.rgb, entityColor.rgb, entityColor.a);

    //Calculate and apply fog intensity.
    if(fogMode == GL_LINEAR){
        float fog = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);		
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    } else if(fogMode == GL_EXP || isEyeInWater >= 1){
        float fog = 1.-clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0., 1.);
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    }

    //Output the result.
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = col;
}
