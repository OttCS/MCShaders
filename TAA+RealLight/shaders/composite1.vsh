#version 120

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

varying vec4 color;
varying vec2 texCoord;

void main()
{
    gl_Position = ftransform();

    color = gl_Color;
    texCoord = (gl_MultiTexCoord0).xy;
}
