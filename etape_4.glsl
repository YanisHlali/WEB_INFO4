    uniform bool isPlayerOffScreen;

    float random(vec2 st, float seed) {
        return fract(sin(dot(st + seed, vec2(12.9898, 78.233))) * 43758.5453123);
    }


    vec3 drawSky(vec2 uv) {
        vec3 skyColor = vec3(0.3, 0.6, 0.9);

        return mix(skyColor, vec3(1.0), pow(1.0 - uv.y, 3.0));
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

    vec3 drawGround(vec2 uv) {
        return groundTexture(uv);
    }


    vec3 drawBlock(vec2 uv) {
        vec3 blockColor = vec3(0.5, 0.3, 0.0);
        float cornerRadius = 0.2;
        float edgeWidth = 0.01;

        vec2 relPos = uv - vec2(0.5, 0.5);
        vec2 distToCorner = abs(relPos) - vec2(0.5 - cornerRadius, 0.5 - cornerRadius);
        float shortestDistToCorner = length(max(distToCorner, 0.0));
        float t = smoothstep(cornerRadius - edgeWidth, cornerRadius, shortestDistToCorner);

        return mix(blockColor, vec3(0.0), t);
    }

    vec3 drawMario(vec2 uv) {
        vec3 hatColor = vec3(0.9, 0.2, 0.2);
        vec3 faceColor = vec3(0.98, 0.8, 0.6);
        vec3 shirtColor = vec3(0.2, 0.5, 0.9);
        vec3 pantsColor = vec3(0.0, 0.0, 0.7);
        vec3 shoesColor = vec3(0.1, 0.1, 0.1);

        float hatRegion = 0.6;
        float faceRegion = 0.4;
        float shirtRegion = 0.25;
        float pantsRegion = 0.1;

        if (uv.y > hatRegion) {
            return hatColor;
        } else if (uv.y > faceRegion) {
            return faceColor;
        } else if (uv.y > shirtRegion) {
            return shirtColor;
        } else if (uv.y > pantsRegion) {
            return pantsColor;
        } else {
            return shoesColor;
        }
    }

    float lastTimePlayerOnLeftEdge = -100.0;

    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = fragCoord / iResolution.xy;
        vec3 col;
        if (uv.y < 0.2) {
            col = drawGround(uv);
        } else {
            col = drawSky(uv);
        }

        float playerPosX = 0.5;
        float playerPosY = 0.2;
        float playerWidth = 0.07;
        float playerHeight = 0.2;
        float cornerRadius = 0.02;
        float edgeWidth = 0.01;

        if (!isPlayerOffScreen && abs(uv.x - playerPosX) < playerWidth / 2.0 && abs(uv.y - playerPosY) < playerHeight / 2.0) {
            vec2 playerUV = (uv - vec2(playerPosX, playerPosY)) / vec2(playerWidth, playerHeight) + 0.5;
            col = drawMario(playerUV);
        }

        float blockSizeX = 0.1;
        float blockSizeY = blockSizeX * iResolution.x / iResolution.y;
        float blockPosY = 0.65;
        float horizontalShift = 0.2;
        float blockSpacing = 0.15;
        vec3 blockColor = vec3(0.5, 0.3, 0.0);
        for (int i = 0; i < 5; i++) {
            float blockPosX = (blockSizeX + blockSpacing) * float(i) + horizontalShift;
            vec2 blockCenter = vec2(blockPosX, blockPosY);
            vec2 relPos = uv - blockCenter;
            vec2 distToCorner = abs(relPos) - vec2(0.5 * blockSizeX - cornerRadius, 0.5 * blockSizeY - cornerRadius);
            float shortestDistToCorner = length(max(distToCorner, 0.0));

            float t = smoothstep(cornerRadius - edgeWidth, cornerRadius, shortestDistToCorner);
            col = mix(col, blockColor, 1.0 - t);
        }
        
        fragColor = vec4(col, 1.0);
    }