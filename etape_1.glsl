vec3 drawSky(vec2 uv) {
    vec3 skyColor = vec3(0.3, 0.6, 0.9);

    return mix(skyColor, vec3(1.0), pow(1.0 - uv.y, 3.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 col;
    col = drawSky(uv);
    fragColor = vec4(col, 1.0);
}
