# AdAstra — habillage intérieur 06

Double-cliquer LANCER.cmd. ZQSD/WASD + souris ; cliquer pour capturer la souris ; Échap pour la libérer ; F2 extérieur ; R cockpit ; F10 quitter.

## Livraison

- Tout l’intérieur reçoit les textures de base : panneaux ivoire, plafond mat, sol souple graphite, métal satiné. Les joints et luminaires structurent les grandes surfaces.
- 33 luminaires importés adaptés, 6 cadres d’accès adaptés et 12 petits éléments muraux.
- Chacune des 6 cabines reçoit 7 modèles : lit, rangement, table, siège, évier, cuisson, réfrigérateur. Les grandes cabines gardent davantage d’espace libre.
- Voir ASSETS.html pour la liste illustrée et les captures, ASSETS.md pour les licences et adaptations.

## Architecture et régénération

Le vaisseau conserve ses 62 m et les six cabines validées. Plans sources, generate.py et blockout.json inchangés lors de cette passe. Les surfaces des cabines restent de 49,83 à 66,30 m². Aucun nouveau mur ou passage.

REGENERER.cmd reconstruit le blockout Blender/GLB. L’habillage est ajouté séparément par godot/interior.gd à partir des cabines et ouvertures de parameters.json. Il est conservé après régénération à dimensions identiques. Une modification importante des dimensions nécessitera une nouvelle vérification du placement des meubles.

## Vérification

105 contrôles réussis : parcours des six cabines, circulation centrale et latérale, cockpit, hangar, commandes FPS et collisions des 42 meubles. 53 maillages structurels conservent leurs collisions. Les éléments de décor légers sont sans collision. Les hashes des références sont inchangés.

Plusieurs lancements avec captures ont permis de corriger la traverse du cadre d’origine, l’aliasing des joints et la dominante trop beige. Mesures aux mêmes points de vue, à 1280 × 800 sur GTX 1070 Ti : environ 16,7 ms par image avant et après, soit 60 images/s avec VSync active. Cela vérifie la fluidité à ce plafond, pas la marge GPU disponible. Les appels de rendu ont augmenté ; une optimisation sera utile si la densité augmente.

## Captures et fichiers

01_couloir_acces.png ; 02_cockpit_baie.png ; 03_conformite_plan.png ; 04_cabine_studio.png ; 05_hangar_raccord.png ; 06_exterieur.png ; 07_grande_cabine.png ; 08_cuisine.png.

test-results.json, performance.json et dressing-manifest.json contiennent les résultats et positions. La version précédente est conservée dans archive/blockout-05 (scripts, paramètres, captures et mesures).

## Provisoire

Salles de bain non cloisonnées ; mobilier encore simple et stylisé, non interactif ; détails du cockpit et portes arrière non travaillés ; extérieur non finalisé. L’éclairage de remplissage est simulé, sans illumination globale calculée. Aucun achat ni publication GitHub.
