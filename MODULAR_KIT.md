# Kit couloir — base réutilisable

## Finition du 13 septembre 2026 (état actuel)

Haut de porte : suppression du cache HeaderWallFinish qui formait une bande grise. L'intervalle au-dessus du cadre abaissé expose directement le linteau d'origine, sans plaque rapportée. Le repère ancien U1, partiellement visible dans cet intervalle, n'est plus créé. Gros plan et vue oblique vérifiés après relancement.

Référentiel géométrique consolidé : les faces intérieures Z=8,036 et Z=9,964 m sont désormais les seules références des modules muraux. Inserts, diffuseurs et soubassements partent de ces plans et avancent uniquement vers le couloir de 4 à 14 mm. Le cadre U1 part du même plan et ses quatre couches fermées totalisent au maximum 25 mm de relief. L'ancienne condition liée à la largeur du cadre, qui pouvait laisser ses montants ouverts après redimensionnement, est supprimée. Validation après lancement par vues de face, à 45 degrés et presque parallèles au mur, incluant le soubassement.

Dernière correction ciblée : le sol du témoin est ivoire satiné, avec joints gris fins. Le graphite des inserts, plinthes, raccords et luminaires est maintenant un gris doux partagé. Les panneaux de part et d'autre de l'accès U1 s'arrêtent aux bords extérieurs du cadre ; aucun insert n'existe derrière les montants. Le cadre courbe est aminci tout en conservant ses retours jusqu'au mur. Les deux gorges hautes et les deux plafonniers du témoin restent symétriques et lumineux. Trois captures inspectées après lancement : axiale, oblique et raccord/porte.

Contrôle complémentaire : cadre épaissi avec retours latéraux jusqu'au mur (les anciennes bandes étaient planes), émission des diffuseurs renforcée. Biais normal des ombres ramené de 1 à 0,02 pour supprimer les fortes stries sur les parois. Grain limité au sol. Relancements Godot et trois captures inspectées après correction ; aucune modification des collisions ou des ouvertures. Les 105 contrôles précédents restent le dernier test de parcours, sans nouvelle campagne.

Portée inchangée : X=18..23 m, passage Z=8..10 m et finition de l'accès existant. Les nœuds sont groupés par module indépendant : Floor, Wall (panneaux pleins + inserts conservés + plinthe anthracite), OpeningFrame, CeilingBays, UpperJunctionAndLight, CeilingLuminaires et Lighting. Matériaux partagés distincts : ivoire satiné, graphite, aluminium, sol gris moyen #939995, plafond mat et diffuseurs. Le shader permet de remplacer la finition sans reconstruire les maillages.

Le plafond utilise quatre travées de 1,25 m ; les deux rives ont le même raccord et un seul diffuseur continu chacune. Deux plafonniers encastrés sont alignés sur les deux sources à ombres. Les faces décoratives minces ne projettent plus d'ombres sur elles-mêmes ; des volumes invisibles dédiés aux ombres représentent les murs pleins, sans collider et sans fermer l'accès. Les normales bruitées des parois sont retirées pour supprimer les stries.

Le marquage rouge hérité au seuil U1 est masqué visuellement ; le sol se prolonge à niveau jusqu'au fond de l'ouverture. Les plinthes s'arrêtent aux montants. Le cadre passe devant le raccord haut et ses jonctions d'arcs partagent leurs sommets sans fissure. Aucune modification de plans, de GLB ou de collisions structurelles.

Validation : 105 contrôles réussis avec fenêtre Godot (parcours, collisions, clavier, souris). La tentative sans fenêtre échouait sur les entrées simulées ; elle ne sert pas de résultat final. Trois captures inspectées : pilot_01_couloir.png, pilot_02_acces.png, pilot_03_raccord.png.

Réutilisation conseillée : murs et cadres pour les accès de cabines, raccords/plafonds pour cockpit, plinthes et matériaux pour hangar avec adaptation de dimensions. Pas d'extension effectuée. Reflets avancés et raccord du témoin à l'ancien habillage extérieur aux cinq mètres restent provisoires.

Le kit est construit dans `godot/pilot.gd` au-dessus du GLB ; il survit donc à une régénération du blockout.

| Module | Composition | Réutilisation prévue |
|---|---|---|
| `wall_panels` | panneau plein ivoire, panneau bas et insert graphite horizontal | circulations, côtés de cabines et hangar |
| `plate` | face arrondie avec biseau et matériau séparé | panneaux pleins, panneaux techniques et cloisons habillées |
| `ceiling_modules` | baie de plafond, fascia, ligne d'ombre et diffuseur intégré | circulations, cockpit et plafond de hangar |
| `door_module` | cadre courbe à retraits, sans porte ni seuil | accès existants des cabines et cockpit |
| `pilot_surface.gdshader` | teinte, rugosité et microrelief procédural | sol, surfaces ivoire et futurs matériaux sans refaire les maillages |

Le soubassement sombre, l'insert horizontal, les bandes lumineuses et le cadre utilisent chacun leur matériau. Les dimensions des modules sont concentrées dans leurs fonctions, pour permettre de modifier un relief ou une finition sans modifier les plans ni les collisions.

Le kit n'ajoute pas de collision : le vaisseau conserve ses collisions structurelles. Les portes arrière, les salles de bain, le mobilier et le traitement spécifique du cockpit restent hors de ce kit.
