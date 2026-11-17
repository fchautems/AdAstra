# Audit de l’existant

Audit du **2026-11-17**, dépôt `fchautems/AdAstra`, branche `main`, commit de départ `fd2760c298ccfd4c0906420e6bdd73c6d74fe61e` (2026-09-20). Copie Git initialement propre, 203 fichiers suivis. Aucun `AGENTS.md` présent dans ce snapshot. Instructions de mission et guide Brain appliqués.

## Réalité constatée

| Élément | Constat dans les fichiers | Réutilisation |
|---|---|---|
| Application | `godot/project.godot`, `main.tscn` et 7 scripts GDScript | Base fonctionnelle existante, à conserver |
| Rendu | `gl_compatibility`, viewport 1280 × 800, physique 120 Hz | Base de comparaison, pas un benchmark GTX 1070 |
| Joueur | `player.gd`, 69 lignes : CharacterBody3D, capsule, souris, gravité, course, signal de pas | Reprendre ; franchissement des marches non implémenté explicitement |
| Structure | `generate.py`, 347 lignes, lit JSON + SVG ; export `adastra.glb` et paramètres | Réutiliser les conventions et outils ; ne pas appliquer la géométrie originale à l’Enterprise |
| Coordonnées | Blender : X/Y du plan, Z vertical ; export Godot : X/Z/−Y | Convention à documenter pour tout nouvel asset |
| Géométrie active | `adastra.glb` : 99 maillages, 287 300 triangles indexés, 9 matériaux, 7 022 844 octets | Structure originale, indépendante de la mission SNW |
| Kit identité | `identity_kit.glb` : 44 maillages, 16 764 triangles, 8 matériaux | Arches, portes, consoles, plateforme à étudier comme composants |
| Habillage | `interior.gd` et `pilot.gd`, maillages/matériaux ajoutés au GLB | Bon principe de séparation structure/décor ; visuel à recaler sur SNW |
| Portes | `identity.gd` : vantaux et corps ; ouverture à <2,5 m, fermeture à >3,2 m, signal audio | Réutiliser le comportement ; vérifier sécurité, collider et orientation lors d’une adaptation |
| Collisions | `main.gd:add_collisions()` crée des trimesh statiques sauf `Guide_`; mobilier séparé | Éviter d’étendre ce calcul à toute une coque détaillée ; prévoir des proxies simples |
| Interface | Accueil, exploration, pause, capture souris, F11, mixeurs audio | Réutiliser ; pas de besoin de nouveau framework UI |
| Audio | `audio.gd`, `sounds/audio_manifest.json`, sources et OGG générés | Pipeline conservé ; droits exacts des sons à compléter avant diffusion nouvelle |
| Contrôles | `--test`, `--identity-check`, vues et mesures dans `main.gd` | Banc de départ ; tests historiques distincts des contrôles de cette mission |

Comptage GLB : lecture des chunks JSON et accessors d’indices, sans modifier ni réexporter les modèles. Il s’agit des fichiers de base, pas de la charge totale après ajout des éléments procéduraux à l’exécution. Voir `evidence.json`.

## Plans et divergences

Le plan source `plans/ship-layout-v1.json` donne 58 m. `blockout.json:cabin_extension` ajoute 4 m sur X entre les abscisses sources 25 et 39 ; `generate.py:X()` étire ce segment. Les paramètres actifs et `plan-conformity.json` donnent **62 m**, six cabines, couloirs 2 m, hauteur intérieure 3 m et hangar 5,5 m. Les valeurs 58 m / hauteur 2 m / hangar 5 m du dossier historique ne décrivent donc pas entièrement l’application actuelle.

Les plans `top-view-v11-base.svg` et `top-view-v14-walls.svg` cités par Brain sont **absents du dépôt AdAstra** audité. Ils ne sont pas pour autant déclarés perdus : les références et archives Brain doivent être conservées. Sont réellement présents dans AdAstra : les deux JSON de plan et `top-and-side-v3.svg`. Aucun n’est remplacé.

Les fichiers `test-results.json`, `performance.json`, `dressing-manifest.json`, le dossier `downloads` et `archive/blockout-05`, cités dans la documentation ancienne, sont **absents de ce snapshot**. Les « 105 contrôles » et 60 FPS historiques ne sont pas des preuves réexécutables à partir de leurs rapports dans ce commit. Le code du banc de contrôles existe, mais les résultats annoncés restent historiques.

## Brain et documents associés

Lecture par le connecteur GitHub : `MODEL_GUIDE.md`, `BRAIN_RULES.md`, `INDEX.md`, `projects/ad-astra.md` et `projects/ad-astra/PROJECT_STATE.md`, ainsi que l’inventaire de son dossier associé. La fiche datée du 11 septembre décrit encore un POC Three.js et aucune tranche Godot ; le dépôt principal contredit cet état. Ses décisions Godot/Blender/hybride restent utiles. Les exigences des six cabines appartiennent au vaisseau original et ne deviennent pas des faits SNW.

`plans/SOURCE_STATE.md` est un état historique de géométrie, pas une instruction de réinitialisation. La mission ajoute des avertissements de portée aux documents d’état et conserve leur contenu antérieur.

## Licences et provenance existantes

- Kenney Furniture et Space Station : fichiers `License.txt` CC0 présents. GLB locaux examinés.
- Quaternius : `godot/assets/pilot/quaternius/License_Standard.txt` présent, CC0 ; `frame.glb` de 192 triangles et textures associé(es) présents. Les packs n’ont pas tous besoin d’être recherchés et importés de nouveau.
- ambientCG : trois ensembles 1K présents ; provenance CC0 documentée dans `ASSETS.md`, licence CC0 revalidée sur la page officielle pendant cette mission.
- Audio : les noms de sources existent, mais le manifeste ne contient pas les URL/auteurs/certificats Pixabay. Leur licence précise est **inconnue dans le dépôt**. Aucun remplacement ni nouveau partage de ces sons pendant l’audit.
- Le manifeste des pas contient `gain_db: 2`, alors que `PROJECT_STATE.md` ancien mentionne 23 dB. Le fichier actif prévaut ; aucun changement audio effectué.
- Aucune licence globale AdAstra n’a été identifiée dans la racine. Cela ne remet pas en cause les licences CC0 locales, et ne permet pas d’inventer une licence pour le code du propriétaire.

## Contrôle d’exécution limité

Copie de `godot/` vers un dossier temporaire, puis import `godot --headless --editor --path … --import` et chargement `godot --headless --path … --quit-after 60`, version **4.6.3 Linux**. L’import termine et le chargement écrit `SCENE_READY meshes_with_collision=56`.

À la sortie : avertissement `ObjectDB instances leaked` et erreur indiquant 8 ressources encore utilisées. L’application n’est donc pas déclarée sans erreur. Ces traces ne permettent pas de qualifier l’impact en jeu ; investigation hors mission documentaire.

Pas de modification du projet original par l’import, pas de lancement du générateur Blender, pas de benchmark GPU, pas de simulation de clavier dans un environnement sans fenêtre. Les anciens tests graphiques sous 4.5.2 et GTX 1070 Ti restent des déclarations historiques, distinctes de la cible **GTX 1070 8 Go**.
