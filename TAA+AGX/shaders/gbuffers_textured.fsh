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

// Gravity Tweaks
uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;

vec3 mix3(vec3 a, vec3 b, vec3 c, float x, float midpoint) {
    if (x <= midpoint) {
        return mix(a, b, smoothstep(0, midpoint, x));
    } else {
        return mix(b, c, smoothstep(midpoint, 1.0, x));
    }
}
// End of Gravity Tweaks

float hspBrightness(vec3 c) {
    return sqrt( .299 * c.r * c.r + .587 *c.g * c.g + .114 * c.b * c.b );
}

vec3 blocklight(float x) {
    return mix3(
        vec3(0.0),
        vec3(0.45, 0.35, 0.3),
        vec3(1.2, 1.1, 1.0),
        x,
        0.77
    );
}

vec3 skycolor(float time) {
    return mix3(
        vec3(0.12, 0.12, 0.19),
        vec3(0.9, 0.6, 0.7),
        vec3(1.2),
        time,
        0.5
    );
}

vec3 skylight(float y) {
    return mix(
        vec3(0.0),
        skycolor(clamp(sin(worldTime * 3.14159265358979323 / 12000.0) + 0.5, 0.0, 1.0)),
        y * y
    );
}

void main()
{
    // vec3 light = texture2D(lightmap, coord1).rgb; // Normal - Don't use it's bad

    // Gravity Tweaks
    vec3 bl = blocklight(coord1.x); // Block light
    vec3 sl = skylight(smoothstep(0.1, 1.0, coord1.y)); // Skylight

    vec3 totalLight = vec3(
        max(bl.r, sl.r),
        max(bl.g, sl.g),
        max(bl.b, sl.b)
    );

    // Eye adjustment
    float eyeExposure = max(
        eyeBrightnessSmooth.x / 240.0 * hspBrightness(blocklight(eyeBrightnessSmooth.x / 240.0)), // Block
        eyeBrightnessSmooth.y / 240.0 * hspBrightness(sl) // Sky
    );
    totalLight /= clamp(eyeExposure, 0.4, 1.1);
    float hsp = hspBrightness(totalLight);
    if (hsp < 0.1) totalLight += 0.1 - hsp;

    vec4 col = color * texture2D(texture, coord0) * vec4(totalLight, 1.0);
    // End of Gravity Tweaks

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
