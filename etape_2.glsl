float random(vec2 st, float seed) {
    return fract(sin(dot(st + seed, vec2(12.9898, 78.233))) * 43758.5453123);
}

float perlinNoise(vec2 uv) {
    vec2 p = floor(uv);
    vec2 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f);

    float a = dot(p, vec2(12.9898, 78.233));
    float b = dot(p + vec2(1, 0), vec2(12.9898, 78.233));
    float c = dot(p + vec2(0, 1), vec2(12.9898, 78.233));
    float d = dot(p + vec2(1, 1), vec2(12.9898, 78.233));

    float n = mix(
        mix(fract(sin(a) * 43758.5453123),
            fract(sin(b) * 43758.5453123), f.x),
        mix(fract(sin(c) * 43758.5453123),
            fract(sin(d) * 43758.5453123), f.x), f.y);
    return n;
}

vec3 groundTexture(vec2 uv) {
    float scale = 1000.0;
    vec2 st = uv * scale;
    float noise = perlinNoise(st);

    vec3 lightGrassColor = vec3(0.3, 0.7, 0.3);
    vec3 darkGrassColor = vec3(0.1, 0.5, 0.1);
    vec3 texColor = mix(lightGrassColor, darkGrassColor, noise);

    return texColor;
}

vec3 drawSky(vec2 uv) {
    vec3 skyColor = vec3(0.3, 0.6, 0.9);

    return mix(skyColor, vec3(1.0), pow(1.0 - uv.y, 3.0));
}

vec3 drawGround(vec2 uv) {
    return groundTexture(uv);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col;
    if (uv.y < 0.2) {
        col = drawGround(uv);
    } else {
        col = drawSky(uv);
    }
    fragColor = vec4(col, 1.0);
}
