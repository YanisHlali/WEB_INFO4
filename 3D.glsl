// Cette variable uniforme indique si le joueur est actuellement hors de l'écran
uniform bool isPlayerOffScreen;

// Cette fonction génère des nombres aléatoires en utilisant une formule mathématique
float random(vec2 st, float seed) {
    // La formule utilise la fonction sin pour générer un nombre compris entre 0 et 1
    return fract(sin(dot(st + seed, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Cette fonction dessine un nuage sur le ciel en utilisant une texture
vec3 drawCloud(vec2 uv, vec2 cloudPos, vec3 bgColor) {
    // La taille du nuage
    float cloudRadius = 0.07;
    // La distance entre la texture actuelle et la position du nuage
    float cloudDist = length(uv - cloudPos);
    // La largeur du bord du nuage
    float cloudEdgeWidth = 0.01;
    // Le coefficient de transition pour mélanger la couleur du nuage et la couleur d'arrière-plan
    float t = smoothstep(cloudRadius - cloudEdgeWidth, cloudRadius, cloudDist);

    vec3 cloudColor = vec3(1.0);
    // Mélange entre la couleur du nuage et la couleur d'arrière-plan
    return mix(cloudColor, bgColor, t);
}

// Cette fonction dessine le ciel avec des nuages
vec3 drawSky(vec2 uv) {
    // La couleur initiale du ciel
    vec3 skyColor = vec3(0.3, 0.6, 0.9);

    // La vitesse de déplacement des nuages
    float cloudSpeed = -0.2;
    // Dessine 10 nuages sur le ciel
    for (int i = 0; i < 10; i++) {
        // La position du nuage en fonction du temps et de son numéro
        vec2 cloudPos = vec2(mod(cloudSpeed * iTime + float(i) * 0.1, 1.0), 0.3 + random(vec2(float(i), 0.0), 0.0) * 0.4);
        // Dessine le nuage sur le ciel
        skyColor = drawCloud(uv, cloudPos, skyColor);
    }

    // Mélange final entre la couleur du ciel et la couleur blanche
    return mix(skyColor, vec3(1.0), pow(1.0 - uv.y, 3.0));
}


// Cette fonction génère du bruit de Perlin en utilisant des formules mathématiques
float perlinNoise(vec2 uv) {
    // Arrondit la valeur `uv` à l'entier inférieur
    vec2 p = floor(uv);
    // Calcule la fraction de la valeur `uv`
    vec2 f = fract(uv);
    // Applique une formule mathématique à la fraction pour obtenir une valeur entre 0 et 1
    f = f * f * (3.0 - 2.0 * f);

    // Calcule la valeur `a` en utilisant la formule dot et la constante `vec2(12.9898, 78.233)`
    float a = dot(p, vec2(12.9898, 78.233));
    // Calcule la valeur `b` en utilisant la formule dot et la constante `vec2(12.9898, 78.233)`
    float b = dot(p + vec2(1, 0), vec2(12.9898, 78.233));
    // Calcule la valeur `c` en utilisant la formule dot et la constante `vec2(12.9898, 78.233)`
    float c = dot(p + vec2(0, 1), vec2(12.9898, 78.233));
    // Calcule la valeur `d` en utilisant la formule dot et la constante `vec2(12.9898, 78.233)`
    float d = dot(p + vec2(1, 1), vec2(12.9898, 78.233));

    // Calcule la valeur finale en utilisant la fonction `mix`
    float n = mix(
        mix(fract(sin(a) * 43758.5453123),
            fract(sin(b) * 43758.5453123), f.x),
        mix(fract(sin(c) * 43758.5453123),
            fract(sin(d) * 43758.5453123), f.x), f.y);
    return n;
}


// Cette fonction crée une texture de sol en utilisant de l'herbe
vec3 groundTexture(vec2 uv) {
    // Un facteur de mise à l'échelle pour la texture
    float scale = 1000.0;
    // Une variable `st` qui représente la position de la texture
    vec2 st = uv * scale;
    // Génère du bruit de Perlin en utilisant la position `st`
    float noise = perlinNoise(st);

    // Couleur claire pour l'herbe
    vec3 lightGrassColor = vec3(0.3, 0.7, 0.3);
    // Couleur foncée pour l'herbe
    vec3 darkGrassColor = vec3(0.1, 0.5, 0.1);
    // Mélange les couleurs claires et foncées en fonction du bruit de Perlin
    vec3 texColor = mix(lightGrassColor, darkGrassColor, noise);

    return texColor;
}

// Cette fonction dessine le sol en utilisant la texture d'herbe
vec3 drawGround(vec2 uv) {
    return groundTexture(uv);
}

// Cette fonction dessine un bloc avec des bords arrondis
vec3 drawBlock(vec2 uv) {
    // Couleur du bloc
    vec3 blockColor = vec3(0.5, 0.3, 0.0);
    // Rayon des coins du bloc
    float cornerRadius = 0.2;
    // Épaisseur des bords du bloc
    float edgeWidth = 0.01;

    // La position relative par rapport au centre du bloc
    vec2 relPos = uv - vec2(0.5, 0.5);
    // La distance entre la position relative et le coin du bloc
    vec2 distToCorner = abs(relPos) - vec2(0.5 - cornerRadius, 0.5 - cornerRadius);
    // La distance la plus courte entre la position relative et un coin du bloc
    float shortestDistToCorner = length(max(distToCorner, 0.0));
    // Un coefficient pour un fondu en douceur des bords arrondis
    float t = smoothstep(cornerRadius - edgeWidth, cornerRadius, shortestDistToCorner);

    // Mélange la couleur du bloc avec du noir en fonction de `t` pour créer les bords arrondis
    return mix(blockColor, vec3(0.0), t);
}

// Fonction pour dessiner Mario
vec3 drawMario(vec2 uv) {
    // Couleurs pour les différentes parties de Mario
    vec3 hatColor = vec3(0.9, 0.2, 0.2);
    vec3 faceColor = vec3(0.98, 0.8, 0.6);
    vec3 shirtColor = vec3(0.2, 0.5, 0.9);
    vec3 pantsColor = vec3(0.0, 0.0, 0.7);
    vec3 shoesColor = vec3(0.1, 0.1, 0.1);
    // Régions pour les différentes parties de Mario
    float hatRegion = 0.6;
    float faceRegion = 0.4;
    float shirtRegion = 0.25;
    float pantsRegion = 0.1;
    // Détermination de la partie de Mario en utilisant la coordonnée Y de l'UV
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

// Temps depuis la dernière fois que le joueur était sur le bord gauche
float lastTimePlayerOnLeftEdge = -100.0;

// Fonction pour dessiner une pièce
vec3 drawCoin(vec2 uv, vec3 bgColor) {
    // Couleur dorée de la pièce
    vec3 coinColor = vec3(1.0, 0.84, 0.0);
    // Rayon du cercle représentant la pièce (50% de la largeur/hauteur)
    float radius = 0.5;
    // Largeur de l'interpolation entre la pièce et l'arrière-plan
    float edgeWidth = 0.01;
    
    // Distance entre le centre de la pièce et la position de la texture
    float dist = length(uv - vec2(0.5, 0.5));
    // Contrôle de l'interpolation entre la pièce et l'arrière-plan
    float t = smoothstep(radius - edgeWidth, radius, dist);

    // Retourne la couleur de la pièce mélangée avec l'arrière-plan en utilisant l'interpolation
    return mix(coinColor, bgColor, t);
}

// Ce code est la fonction principale qui détermine la couleur de chaque pixel à afficher sur l'écran.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy; // Convertit les coordonnées de pixel en coordonnées normalisées
    vec3 col; // Déclare la variable de couleur

    // Détermine si le fond est le ciel ou le sol en fonction de la position Y de l'UV
    if (uv.y < 0.2) {
        col = drawGround(uv); // Dessine le sol
    } else {
        col = drawSky(uv); // Dessine le ciel
    }

    float playerSpeed = 0.5; // La vitesse du joueur
    float playerPosX = mod(playerSpeed * iTime, 1.); // La position horizontale du joueur est déterminée en fonction du temps
    float jumpHeight = 0.38; // Hauteur du saut du joueur
    float jumpDuration = 1.0; // Durée du saut du joueur
    float playerPosY = 0.1 + jumpHeight * abs(sin(iTime / jumpDuration * 3.14159)); // La position verticale du joueur est déterminée en fonction du temps

    // Définit les dimensions et la forme du joueur
    float playerWidth = 0.07;
    float playerHeight = 0.2;
    float cornerRadius = 0.02;
    float edgeWidth = 0.01;

    // Vérifie si le joueur n'est pas en dehors de l'écran et si l'UV se trouve dans la région du joueur
    if (!isPlayerOffScreen && abs(uv.x - playerPosX) < playerWidth / 2.0 && abs(uv.y - playerPosY) < playerHeight / 2.0) {
        vec2 playerUV = (uv - vec2(playerPosX, playerPosY)) / vec2(playerWidth, playerHeight) + 0.5;
        col = drawMario(playerUV); // Dessine le joueur
    }

    // Dessine les blocs
    float blockSizeX = 0.1; // Largeur d'un bloc
    float blockSizeY = blockSizeX * iResolution.x / iResolution.y; // Hauteur d'un bloc en fonction de la largeur
    float blockPosY = 0.65; // Position Y des blocs
    float horizontalShift = 0.2; // Décalage horizontal des blocs
    float blockSpacing = 0.15; // Espacement entre les blocs
    vec3 blockColor = vec3(0.5, 0.3, 0.0); // Couleur des blocs
    // Boucle qui dessine 4 blocs sur l'écran
    for (int i = 0; i < 5; i++) {
        float blockPosX = (blockSizeX + blockSpacing) * float(i) + horizontalShift; // Calcul de la position X du bloc
        vec2 blockCenter = vec2(blockPosX, blockPosY); // Centre du bloc
        vec2 relPos = uv - blockCenter; // position relative de l'UV par rapport au centre du bloc
        vec2 distToCorner = abs(relPos) - vec2(0.5 * blockSizeX - cornerRadius, 0.5 * blockSizeY - cornerRadius); // Distance à l'angle du bloc
        float shortestDistToCorner = length(max(distToCorner, 0.0)); // Distance la plus courte à l'angle du bloc

        // Vérifie si l'UV se trouve dans la région du bloc
        float t = smoothstep(cornerRadius - edgeWidth, cornerRadius, shortestDistToCorner);
        // Mélange la couleur du bloc avec l'arrière-plan en utilisant l'interpolation
        col = mix(col, blockColor, 1.0 - t);
    }

    float coinDuration = 3.0; // Durée de l'affichage de la pièce
    float coinPosY = 0.85; // Position Y de la pièce
    
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

        // Vérifie si la position actuelle de l'UV est à l'intérieur des limites de la pièce
        if (abs(uv.x - newCoinPosX) < coinWidth / 2.0 && abs(uv.y - newCoinPosY) < coinHeight / 2.0) {
            // Calcule la position relative de l'UV par rapport à la pièce
            vec2 coinUV = (uv - vec2(newCoinPosX, newCoinPosY)) / vec2(coinWidth, coinHeight) + 0.5;
            // Dessine la pièce en utilisant la position relative de l'UV
            col = drawCoin(coinUV, col);
        }
    }

    fragColor = vec4(col, 1.0);
}