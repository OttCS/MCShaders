# Features
This shader is intended to be a "realification" of Minecraft as-is: Using the internal day/night times and light values and correcting them to have real-world colors and luminance.

## TAA
Temporal Anti-Aliasing is fairly cheap for decent results, even if it's a little blury in motion

## RealLight
Real-world accurate lighting, accounting for:

- Color temperature of light sources (sun, moon, blocks)
- Lux intensity of light sources
- Rods/Cones wavelength and lux response curves (including Purkinje effect)

# Research
This took a lot of Desmos and a lot of internet searching, but here's what I used to create this mess

## Color Temperature
Kelvin is a unit of "color warmness" based on black body radiation.

- **Daylight** is ~6500K, or just barely off white.
- **Sunrise/set** is 4500Kish.
- **Moonlight** is 4100K, warmer than sunlight, but we see it as cool due to the Purkinje effect.
- **Blocklight** I'm considering to be 3000K, which is comparable to a warm halogen.

## Lux Intensity
https://en.wikipedia.org/wiki/Lux

Lux is essentially "illumination power in one square meter" which works well for Minecraft.

- **Noonlight** is 10k lux
- **Moonlight** is 0.3 lux
- **Sunrise/set** clocks in around 400 lux
- **Blocks** I'm considering to be 500 lux for the brightest ones (glowstone, redstone lamps, etc)

Minecraft sky light value to lux = 10000 * pow(x / 15, 7);
Minecraft block light value to lux = 500 * pow(x / 15, 3);

## Rods/Cones Wavelength response curves
Refer to: https://en.wikipedia.org/wiki/Purkinje_effect

The cones in your eye take over in low light situations, which are actually tuned to a mostly-green turquoise.


