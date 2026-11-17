# Code réutilisable et coûts d’adaptation

Audit statique au 2026-11-17. Les huit dépôts ci-dessous ont été clonés et leurs fichiers ciblés réellement lus. Aucun code tiers n’est intégré à AdAstra et aucune démo tierce n’a été exécutée. « Candidat » signifie que l’intérêt et les interfaces sont identifiés, pas qu’un import est validé.

## Priorités d’intégration futures

| Fonction | Déjà dans AdAstra | Choix proposé | À développer / vérifier |
|---|---|---|---|
| Marche, course, regard, pause | `player.gd`, `ui.gd`, `main.gd` | Conserver | Confort, accessibilité, sauvegarde de position si souhaitée |
| Marches et changements de niveau | Gravité/floor snap seulement | Adapter C01 | Intégrer rayons auxiliaires, filtrage, seuil de marche ; tester les marches de la passerelle |
| Porte coulissante et son | `identity.gd`, `audio.gd` | Conserver et isoler en scène réutilisable lors d’un futur chantier | Sécurité anti-fermeture sur joueur, état verrouillé, orientation et vitesse configurables |
| Bouton/console ciblés | Pas de contrat générique identifié | C02 `Interactable` + `Interaction` | Action clavier, longueur/masque du rayon, message d’action et retour audio |
| Turbolift | Absent | Petite machine à états spécifique sur les outils Godot existants | Appel, attente, portes, déplacement ou transition, destination, verrouillage et sauvegarde |
| Assemblage de pièces | Générateur JSON/SVG | Conserver les outils ; emprunter le principe de connecteurs C04 | Contrat local de raccord, validation dimensionnelle et graphe de circulation |
| Simulation des systèmes de bord | Absente | Différer ; C09/C10 en références | Les simulateurs complets ne sont pas nécessaires pour une visite |

## Inspection approfondie des huit dépôts

### C01 — Majikayo, marches

[Dépôt](https://github.com/majikayogames/godot-character-controller-stairs), snapshot `e067dd13fa37072cf4836639505db170c49733da`, dernier commit 2023-12-28. Godot 4.2 Compatibility, GDScript. 21 fichiers suivis. `entities/Player/Player.gd` utilise `_snap_down_to_stairs_check()`, `PhysicsServer3D.body_test_motion()` et des rayons de séparation orientés avec le mouvement. `Player.tscn` fournit les nœuds auxiliaires. Le modèle de démonstration n’est pas un asset SNW.

Licence CC0 **avec** `THIRD_PARTY_LICENSES` MIT de LegionGames : ne pas supprimer cet avis lors d’une reprise. Intérêt élevé pour le franchissement des marches, intégration estimée faible à moyenne ; ne pas importer les effets de caméra si le confort actuel est préféré. Comparer marche diagonale, descente en course et plafond bas.

### C02 — snddude, interactions

[Dépôt](https://github.com/snddude/godot-interaction_system), snapshot `9b43c0838de6f66d76e6d66c9ae138116bf360b9`, 2026-10-23. 68 fichiers suivis, MIT. Les deux scripts utiles sont dans `addons/interaction_system/scripts/components/`. `Interactable` place un callable en metadata du parent ; `Interaction.interact()` consulte le collider atteint par RayCast et appelle cette fonction. Les icônes référencées doivent accompagner les scripts.

Le composant n’apporte ni logique de porte, ni message d’aide complet, ni inventaire. Il fournit précisément le contrat qui manque pour activer une console. Le collider visé doit être le parent portant le metadata ; un maillage enfant seul ne suffit pas. La démo déclare Godot 4.7 et embarque d’autres plugins ; **ne pas importer toute la démo**. Portabilité des deux scripts sur 4.5.2 à vérifier avant décision de version.

### C03 — Quality First Person Controller v2

[Dépôt](https://github.com/ColormaticStudios/quality-godot-first-person-2), snapshot `27fab75ca8f6d949d887e9f3f9008c2b0e8bb603`, 2026-09-30. 28 fichiers suivis, MIT. Inspection de `addons/fpc/character.gd`, scène, README et licence. Caméra, états de déplacement et options paramétrables ; utile pour comparer un contrôleur complet.

Le gain est moins clair qu’un ajout ciblé à `player.gd` : les commandes, pause, sons et tests d’AdAstra sont déjà câblés. Le README préconise un réglage de pente et snap pour les escaliers ; ce n’est pas une preuve que toutes les géométries SNW fonctionnent. La [fiche Asset Library 2087](https://godotengine.org/asset-library/asset/2087) est explicitement dépréciée, ne pas repartir de cette ancienne distribution.

### C04 — SimpleDungeons

[Dépôt](https://github.com/majikayogames/SimpleDungeons), snapshot `15b32406e2f10c55cdb864e18661137bacfead89`, 2025-04-02. 108 fichiers suivis, CC0, démo Godot 4.2 Forward+. `DungeonRoom3D.gd` décrit taille, grille, portes et chevauchements ; `DungeonGenerator3D.gd` orchestre génération, chemins, erreurs et tentatives.

Intérêt : conventions de connexions et validation de modules. Ne pas utiliser une disposition aléatoire pour des décors dont les accès doivent reproduire les références. La démo contient des ressources de jeu sans rapport avec SNW. L’extraction des seuls concepts de raccord est plus légère que l’adoption du générateur complet ; effort moyen si véritable intégration du plugin.

### C05 — RodZill4 Procedural3D, ancien

[Dépôt](https://github.com/RodZill4/godot-procedural3d), snapshot `3113abadc77155e99cdc17da3efb009dd09cf0ee`, 2019-01-21. 410 fichiers suivis, code MIT. `generator.gd`, `modular_room.gd` et `modular_room_exit.gd` illustrent raccordement par sorties. `project.godot` et les API correspondent à Godot 3.x.

Projet ancien conservé comme référence utile, sans affirmer qu’il est officiellement archivé. Port Godot 4 et licences des assets de démo à traiter séparément. C04 offre une base plus proche de l’environnement actuel ; reprise immédiate écartée.

### C06 — MacdonaldRobinson, inventaire et ascenseur

[Dépôt](https://github.com/MacdonaldRobinson/Godot4-3D-inventory-and-interaction-system), snapshot `299b115511fb830f50d0d06ea9d9fbf2dcb2da80`, 2024-06-10. Godot 4.0 Compatibility, GDScript. README, porte, bouton et scène d’ascenseur examinés. Aucun fichier LICENSE/COPYING trouvé.

`Door.gd` cherche une clé et joue une animation. `Elevator.gd` est un squelette ; **`Elevator/Button.gd` commute cependant une animation Floor2 en avant/arrière**, présente dans la scène. Il serait incorrect de dire que tout l’ascenseur est absent. Il s’agit d’un exemple à deux positions, pas d’un turbolift multi-ponts. Pas de reprise autorisée établie : garder l’idée de comportement, demander une licence seulement si ce code devient réellement utile.

### C07 — paarthbhatt, simulateur Enterprise web

[Dépôt](https://github.com/paarthbhatt/Star-Trek), snapshot `601d886f0777a619621a5314cfad9870e07c4d0c`, 2026-01-06. 84 fichiers suivis ; code MIT. Next.js/React/Three.js et Zustand, donc port d’interactions et de scènes nécessaire vers Godot.

`PROJECT_ANALYSIS.md` annonce `enterprise.glb` 4,8 Mo et `bridge.glb` 111 Mo. **Aucun GLB ni composant de passerelle correspondant n’a été trouvé dans le snapshot.** `Enterprise.tsx` construit une coque procédurale d’environ 2,8 unités à échelle ~1:100 ; le projet porte surtout sur le pilotage. README et arborescence divergent. Ne pas compter sur les fichiers annoncés pour éviter de modéliser une passerelle ; licence/provenance de ces modèles inconnues.

### C08 — NetTrekUnity

[Dépôt](https://github.com/pg07gordon/NetTrekUnity), snapshot `7698bcfd9e4fc245841802475b737cfc3cdc8bf3`, 2017-08-31. 600 fichiers suivis. README, scripts PlayerController/GameManager et métadonnées projet examinés. DoTween Pro à licencier séparément selon README ; provenance multiple d’assets de mods Bridge Commander.

Pas de scène SNW moderne validée, pas de licence globale standard identifiée, port Unity nécessaire. Aucun asset de jeu extrait ou réutilisé. Ce dépôt ne résout pas le besoin de références fiables et d’intérieur FPS SNW : écarté.

## Autres projets et faux positifs conservés

Space Nerds in Space et EmptyEpsilon : racine, dépendances, licence et métadonnées consultées. GPL-2.0, moteurs C/OpenGL et C++/SeriousProton ; leurs logiques de postes sont des références pour une phase de simulation future. Pas d’audit complet de leur code métier, donc aucun module précis déclaré prêt à porter.

Stage 9 et les anciens projets Enterprise-D/Unreal sont des références de qualité et d’expérience, pas une bibliothèque libre. L’auteur de Stage 9 interdit reprise et rétro-ingénierie. Aucun miroir n’est utilisé.

GitLab ESR Super Star Trek : jeu textuel, hors besoin 3D. `beatricepedretti/USS_ENTERPRISE`, remonté par la recherche GitHub, concerne un bras robotique à ultrasons : éliminé sur sa description, sans exploiter son contenu. Aucun dépôt public de reconstruction SNW complet et licencié n’a été validé dans cette recherche.

## Conclusion de l’audit de code

Le plus gros travail évitable est **déjà évité dans AdAstra** : FPS, collisions de base, portes, menus et audio existent. Les nouveaux apports les plus crédibles sont C01 et C02. Un ascenseur sécurisé, les états des consoles et le chargement de secteurs restent à adapter/développer ; aucun framework inspecté ne fournit magiquement le vaisseau SNW.
