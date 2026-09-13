# Couloir témoin — kit visuel original

État courant du 13 septembre : voir la section de finition de MODULAR_KIT.md. Sol gris moyen, seuil rouge masqué et finition affleurante, raccords symétriques, plinthes et modules regroupés, suppression des stries. 105 contrôles réussis avec fenêtre. Captures actuelles : pilot_01_couloir.png, pilot_02_acces.png, pilot_03_raccord.png. Le contenu ci-dessous décrit les passes antérieures.

## Correction actuelle — sol clair et reliefs

Cette section remplace les descriptions de finition de la première passe ci-dessous. Le témoin reçoit désormais un sol gris perle #CCCFC9, à joints de 1,25 m et microvariation procédurale de couleur, normale et rugosité (0,32). Les panneaux ivoire #E9E7DF ont une géométrie arrondie et un biseau de 12 mm ; les inserts sont désormais visibles côté couloir. Le cadre est un contour courbe à retraits superposés, placé autour du passage et non à l'intérieur. Les limites intérieures restent hors des 1,20 m libres et les arcs commencent au-dessus du linteau existant. Aucun collider n'est ajouté.

Deux spots orientés vers le bas remplacent les points lumineux sans ombres ; ombres actives, couche 2 réservée au témoin, portée 3,5 m. Le sol et les panneaux utilisent `pilot_surface.gdshader`, matériau PBR procédural original sans téléchargement ni carte externe. Le petit module isolé du mur gauche a été retiré. La transition au sol de l'accès reste celle du blockout existant : aucun seuil décoratif ambigu n'est ajouté.

Validation limitée : lancement Godot réussi, 53 collisions structurelles chargées, assertion de largeur du cadre réussie. Deux captures récentes : `pilot_01_couloir.png` et `pilot_02_acces.png`. La capture `pilot_03_sol.png` appartient à la passe précédente. Pas de nouveau parcours FPS complet ni benchmark. Voir aussi `MODULAR_KIT.md`.

Écarts encore visibles : reflets beaucoup plus discrets que dans les références, éclairage encore uniforme et légères stries sur certaines parois. Les arrondis et la couleur du sol sont maintenant lisibles ; la fidélité au décor de référence reste partielle. Aucun habillage généralisé.

Tronçon : X=18..23 m, Z Godot=8..10 m. L'accès U1, le volume, les passages, le sol structurel et les collisions restent inchangés. F3 dans le jeu amène au début du témoin.

## Kit actif

- panneaux ivoire satinés, avec joints de 3 mm et inserts graphite ponctuels ;
- sol graphite gris satiné ;
- plafond blanc cassé à grands panneaux ;
- gorges lumineuses continues dans les raccords plafond/mur ;
- cadre d'accès à chanfreins doux, placé autour de l'ouverture libre existante ;
- un panneau technique fermé et un voyant discret.

Tous ces éléments sont des maillages paramétriques construits par `godot/pilot.gd`. Ils n'utilisent plus le cadre, les panneaux ou les luminaires provenant de packs externes. Les matériaux utilisent des propriétés physiques de rugosité et de métal : ivoire `.60`, plafond `.75`, sol `.40`, graphite `.52`, aluminium `.36 / métallique 1`.

Deux sources lumineuses et une sonde de réflexion locale éclairent le témoin. Les diffuseurs visibles font partie de la géométrie. Aucun seuil, vantail, mobilier, panneau d'écran, ni nouvelle fonction de pièce n'a été ajouté.

## Contrôle minimal

Le projet a été importé et lancé en mode capture le 12 septembre 2026. `SCENE_READY meshes_with_collision=53` confirme que la scène continue de charger avec ses collisions structurelles. Les trois vues produites sont `pilot_01_couloir.png`, `pilot_02_acces.png` et `pilot_03_sol.png`.

Ce contrôle est limité à l'import, au lancement et aux vues du témoin demandées. Il ne constitue pas une campagne de tests FPS ou de performances.

## Suite

La généralisation est volontairement bloquée jusqu'à validation humaine de ce témoin. `VISUAL_DIRECTION.md` fixe les couleurs, proportions de panneaux et règles de réutilisation.
