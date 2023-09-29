//Jitter offset from Chocapic13, BSL 8V.2.05
uniform float framemod8;
uniform float framemod2;

// Halton Sequence for better distribution?
// vec2 jitterOffsets8[8] = vec2[8](
// 							vec2( 0.0,−0.167),
// 							vec2(-0.25, 0.167),
// 							vec2( 0.25,−0.389),
// 							vec2(−0.375,−0.056),
// 							vec2( 0.125, 0.278),
// 							vec2(−0.125,−0.278),
// 							vec2( 0.375, 0.056),
// 							vec2(−0.437, 0.389)
// 						);
vec2 jitterOffsets8[8] = vec2[8](
							vec2( 0.125,-0.375),
							vec2(-0.125, 0.375),
							vec2( 0.625, 0.125),
							vec2( 0.375,-0.625),
							vec2(-0.625, 0.625),
							vec2(-0.875,-0.125),
							vec2( 0.375,-0.875),
							vec2( 0.875, 0.875)
						);
vec2 jitterOffsets2[2] = vec2[2](
							vec2( 1.0,  0.0),
							vec2( 0.0,  1.0)
						);
							   
vec2 TAAJitter(vec2 coord, float w) {
	#if TAA_MODE == 0
	vec2 offset = jitterOffsets8[int(framemod8)] * (w / vec2(viewWidth, viewHeight));
	#else
	vec2 offset = jitterOffsets2[int(framemod2)] * (w / vec2(viewWidth, viewHeight));
	#endif
	return coord + offset;
}