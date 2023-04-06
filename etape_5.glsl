    uniform bool isPlayerOffScreen;

    float random(vec2 st, float seed) {
        return fract(sin(dot(st + seed, vec2(12.9898, 78.233))) * 43758.5453123);
    }

    vec3 drawCloud(vec2 uv, vec2 cloudPos, vec3 bgColor) {
        float cloudRadius = 0.07;
        float cloudDist = length(uv - cloudPos);
        float cloudEdgeWidth = 0.01;
        float t = smoothstep(cloudRadius - cloudEdgeWidth, cloudRadius, cloudDist);

        vec3 cloudColor = vec3(1.0);
        return mix(cloudColor, bgColor, t);
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

    vec3 drawCoin(vec2 uv, vec3 bgColor) {
        vec3 coinColor = vec3(1.0, 0.84, 0.0); // Couleur dorée
        float radius = 0.5; // Rayon du cercle (50% de la largeur/hauteur)
        float edgeWidth = 0.01; // Largeur de l'interpolation entre la pièce et l'arrière-plan
        
        float dist = length(uv - vec2(0.5, 0.5));
        float t = smoothstep(radius - edgeWidth, radius, dist);

        return mix(coinColor, bgColor, t);
    }

    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = fragCoord / iResolution.xy;
        vec3 col;
        if (uv.y < 0.2) {
            col = drawGround(uv);
        } else {
            col = drawSky(uv);
        }

        float playerSpeed = 0.5;
        float playerPosX = mod(playerSpeed * iTime, 1.);
        float jumpHeight = 0.38;
        float jumpDuration = 1.0;
        float playerPosY = 0.1 + jumpHeight * abs(sin(iTime / jumpDuration * 3.14159));
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

        float coinDuration = 3.0;
        float coinPosY = 0.85;
        
        if (playerPosY > 0.46) {
            // Affiche une pièce au-dessus de la position du joueur lorsque Mario est au-dessus de 0.45
            float playerPosX = mod(playerSpeed * iTime, 1.);
            float coinWidth = 0.08;
            float coinHeight = coinWidth * iResolution.x / iResolution.y;

            // Trouvez l'index du bloc le plus proche
            int closestBlockIndex = int(floor((playerPosX - horizontalShift) / (blockSizeX + blockSpacing)));

            // Calculez la position x du bloc le plus proche
            float closestBlockPosX = (blockSizeX + blockSpacing) * float(closestBlockIndex) + horizontalShift;

            // Calculez la position y du bloc le plus proche
            float closestBlockPosY = blockPosY;

            // Modifiez la valeur de coinPosY pour correspondre à celle du bloc le plus proche
            float newCoinPosY = (closestBlockPosY + blockSizeY / 2.0 + coinHeight / 2.0) + 0.05;

            // Modifiez la valeur de coinPosX pour correspondre à celle du bloc le plus proche
            float newCoinPosX = closestBlockPosX;

            if (abs(uv.x - newCoinPosX) < coinWidth / 2.0 && abs(uv.y - newCoinPosY) < coinHeight / 2.0) {
                vec2 coinUV = (uv - vec2(newCoinPosX, newCoinPosY)) / vec2(coinWidth, coinHeight) + 0.5;
                col = drawCoin(coinUV, col);
            }
        }

        fragColor = vec4(col, 1.0);
    }