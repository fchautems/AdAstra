# Architecture proposée et première réalisation

**Recommandation du 2026-11-17 : conserver Godot 4 + Blender et la base fonctionnelle actuelle.** Il s’agit d’une recommandation technique préparée, sans changement de moteur, de version, de code ou de géométrie effectué.

## Comparaison des stratégies

| Stratégie | Gain concret | Coût / limite | Choix |
|---|---|---|---|
| Scène Godot existante | FPS, portes, UI, audio et conventions déjà câblés | Géométrie et style actuels ne représentent pas l’Enterprise | Réutiliser l’infrastructure, conserver le vaisseau original séparément |
| Import GLB/glTF d’un modèle autorisé | Maillages, textures PBR standard et animations transférables | Un import ne prouve ni échelle, ni collisions, ni fidélité ; fichiers SNW complets non validés | Voie préférée pour assets réellement obtenus et autorisés |
| Import `.blend` direct | Itération rapide en création | Appelle Blender pour conversion ; installation/version requise sur chaque poste | Utiliser pour travail d’atelier ; livrer des GLB reproductibles au runtime |
| FBX / OBJ | Réemploi d’anciens assets | Vérifier échelles/pivots ; OBJ ne conserve pas une scène animée/PBR complète | Conversion Blender contrôlée ; GLB final préféré |
| Projet Unity | Réemploi éventuel de maillages et textures accessibles | Scripts C#, prefabs, UI et shaders ne deviennent pas du GDScript ; licences par dépendance | Aucun candidat inspecté ne justifie un changement de moteur |
| Projet Unreal | Réemploi d’assets exportables si droit et source disponibles | Blueprints, matériaux et logique à porter ; `.uasset` seul n’est pas un fichier d’échange Blender | Références seulement à ce stade ; pas de pack SNW complet autorisé validé |
| Génération paramétrique depuis plans | Modules cohérents et variantes reproductibles ; outils Python déjà présents | Relevé fiable nécessaire ; mobilier spécifique toujours à produire | Retenir pour architecture répétitive et modules de couloir |
| Kit générique complet | Quelques modules et props déjà construits | Style souvent industriel ou TNG ; risque de répéter le résultat générique déjà obtenu | Employer en appoint, ne pas en faire la direction artistique |
| Hybride | Infrastructure existante + détails SNW sur références + props secondaires | Harmonisation de matériaux et contrôle par scène | **Option retenue comme recommandation** |

Références primaires : [importeurs Godot](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html), [rendu Godot 4.5](https://docs.godotengine.org/en/4.5/tutorials/rendering/renderers.html). Les conversions sont des possibilités techniques, non une permission de copier les fichiers d’une autre application.

## Organisation cible proposée

Conserver les fichiers actuels à leur place. Dans un chantier ultérieur, introduire une entrée distincte SNW et des scènes réutilisables par zone. Proposition de responsabilités :

| Couche | Contenu | Règle |
|---|---|---|
| Références | Identifiants de ressources, pages, saisons, dimensions et degré de certitude | Métadonnées dans Git ; sources protégées conservées chez leurs auteurs |
| Plans SNW futurs | Graphe pièce/accès/pont et dimensions sourcées | Données distinctes de `plans/ship-layout-v1.json` original |
| Sources Blender | Collections par module, pivots et variantes | 1 unité = 1 m ; orientation unique, échelle appliquée, aucune dépendance au placement global |
| Assets d’échange | GLB par salle/module et textures partagées | Géométrie, matériaux PBR, UV2 pour surfaces éclairées par lightmaps, proxies de collision séparés |
| Scènes Godot | Structure statique, décor, portes, interactions et audio séparés | Ne pas recréer tous les colliders depuis des maillages décoratifs détaillés |
| Runtime | Joueur actuel, UI, catalogue de zones, état des portes/consoles | Réemploi ciblé, pas de réécriture du jeu existant |
| Chargement | Pièce courante et voisines, transitions turbolift | Ne pas garder tous les ponts détaillés visibles et actifs en permanence |

Contrat de module proposé : identifiant, dimensions, niveau de sol, origine locale, connecteurs nommés avec transform et section libre, variante/saison, collisions, points d’interaction, provenance et licence. Un connecteur ne peut être accepté si la capsule du joueur et sa marge ne passent pas. Les inconnues dimensionnelles restent distinctes des dimensions de travail choisies.

## Pipeline futur d’une ressource tierce

1. Vérifier le fichier réellement disponible, auteur, droits, format, textures et licence de cette version ; conserver une preuve d’acquisition si payant. Ne pas acheter automatiquement.
2. Ouvrir en quarantaine dans Blender, inspecter unités, orientation, UV, normales, matériaux, pivots, nombre de surfaces, textures et dépendances. Aucun binaire de jeu extrait.
3. Réduire les matériaux redondants, préparer LOD/proxies et convertir les shaders procéduraux non portables en PBR/texture si nécessaire. Les écrans doivent utiliser des graphismes propres au projet ou autorisés.
4. Exporter un GLB reproductible et le tester seul dans Godot : dimensions, collision, animation, double face, rugosité, canal normal OpenGL et textures manquantes.
5. Valider à hauteur d’œil contre des références comparables, puis mesurer sur le PC cible. Garder la licence et les modifications avec l’asset ; publier uniquement ce qui est autorisé.

CC BY impose notamment attribution et indication des modifications ; ce n’est pas une autorisation sur toutes les marques ou créations représentées. Les licences Fab doivent être vérifiées par produit ; certains contenus ne sont que référencés ou portent des restrictions supplémentaires. Références : [CC BY](https://creativecommons.org/licenses/by/4.0/), [Fab](https://www.fab.com/eula). Stage 9 est exclu par interdiction explicite. Les articles et images de production ne deviennent pas des assets de jeu libres.

## Rendu et cible GTX 1070 8 Go

La scène actuelle fonctionne en Compatibility. **Ne pas imposer un changement maintenant.** Prévoir plus tard une comparaison limitée entre la base Compatibility et un profil Forward+ avec illumination principalement précalculée et sondes. Le choix final dépend du rendu obtenu et des mesures sur Windows/GTX 1070 ; le résultat historique sur une GTX 1070 Ti à VSync 60 ne prouve pas la marge sur cette cible.

Recommandations de budget pour le témoin, à considérer comme hypothèses de production révisables :

| Mesure | Cible proposée, pas résultat mesuré |
|---|---|
| Résolution | 1920 × 1080, profil cible documenté ; 1280 × 800 en repli |
| Cadence | Médiane ≥60 FPS, 1 % bas ≥45 FPS pendant un parcours de 3 minutes ; VSync désactivée pour mesure |
| Temps d’image | Budget moyen ~16,7 ms ; mesurer GPU/CPU et pics lors d’ouverture de porte |
| VRAM | Pic mesuré ≤6 Go pour garder de la marge sur 8 Go ; ne pas le déduire de la taille des fichiers |
| Géométrie visible | Budget de départ ≤1 million de triangles et ≤500 appels de rendu ; ajuster selon mesures, pas un plafond moteur |
| Textures | 1K/2K partagées ; 4K réservées aux éléments réellement proches, pas chaque panneau |
| Éclairage | Précalcul et sondes pour l’essentiel ; peu de lumières à ombres actives et pas toutes les pièces simultanément |
| Charge du vaisseau | Secteurs et occlusion ; scripts, animations et sons des zones lointaines désactivés |

La réalisation du volume LED de machines ne nécessite pas de reproduire le pipeline de tournage ni ses centaines de sources. Un effet lumineux émissif ne remplace pas automatiquement un éclairage reçu par les surfaces. Éviter SDFGI et effets coûteux comme dépendances obligatoires avant benchmark.

## Première réalisation proposée, non implémentée

**Un secteur arrière de la passerelle SNW, son accès turbolift, la cabine du turbolift et 4 à 6 m de couloir témoin.** La longueur de couloir est une dimension de travail proposée, pas une cote officielle. Les raccords hors de la passerelle doivent rester étiquetés comme interprétation tant que les documents ne les prouvent pas. Cette zone démontre courbes, niveaux, consoles, porte, éclairage et circulation sans demander toute la passerelle ni toute la coque.

Pièces de référence à figer : P01 p.68–74 et p.95–97, P03, P08/P09 et photos finales P15. Choisir une seule version visuelle de départ (proposition : saison 1), conserver les variantes ultérieures dans le catalogue. Relever le secteur et ses accès avant d’assembler les volumes. Prévoir un cadrage qui montre le poste de commandement ou sa silhouette sans prétendre livrer toute la pièce.

### Critères observables de réussite

| Critère | Contrôle attendu lors de la future réalisation |
|---|---|
| Fidélité identifiable | 3 vues à hauteur d’œil, focale/FOV documentés, comparées à 3 références finales de la même version ; aucune substitution TNG/Kelvin |
| Géométrie | Cotes du dossier de zone reliées à leur feuille ; toute cote choisie reste marquée hypothèse ; pas de murs traversants ni surfaces superposées aux raccords |
| Déplacement | Trajet continu passerelle → porte → cabine → couloir ; marches montées/descendues sans saut imposé, sans blocage ni traversée |
| Porte | 20 cycles sans accrocher le joueur ; fermeture empêchée en présence dans la baie ; son relié à l’état réel |
| Interaction | Une console activable à distance définie, retour visuel lisible, état conservé pendant la session ; pas d’interaction à travers une cloison |
| Qualité visuelle | Matériaux distincts, panneaux et éclairages intégrés, ombres sans stries, exposition stable ; inspection face, oblique et angle rasant |
| Confort | Souris/pause/reprise/F11 fonctionnent ; vitesse et hauteur actuelles conservées sauf décision explicite ; pas de balancement de caméra forcé |
| Performance | Parcours et compteurs selon le budget ci-dessus sur Windows/GTX 1070, avec version moteur/pilote, réglages et traces enregistrés |
| Reproductibilité | Export du secteur reproductible sans toucher à l’original ; aucun chemin absolu requis chez l’utilisateur |
| Préservation | L’entrée existante et ses fichiers protégés gardent leurs empreintes ; toutes les licences de nouveaux fichiers sont présentes |

### Difficulté et charge de travail

Estimations de planification propres à cette proposition, **non mesurées**, pour un auteur sachant travailler dans Blender/Godot avec assistance :

| Lot | Difficulté | Effort indicatif |
|---|---|---|
| Relever les plans et verrouiller les 3 références | Moyenne | 4–10 h |
| Préparer quelques modules courbes et éléments signature | Élevée | 16–35 h |
| Réemployer joueur/porte, adapter marches et une interaction | Moyenne | 5–12 h |
| Éclairage, matériaux et harmonisation | Élevée | 8–18 h |
| Parcours, vérifications et ajustements Windows | Moyenne | 4–10 h |
| **Témoin complet** | **Moyenne à élevée** | **37–85 h**, à recalibrer après premier module |

Pour les 12 familles d’espaces avec réemploi des modules et des détails denses seulement dans les zones visitées : ordre de planification **350–900 h**. L’ingénierie et les pièces à forte identité peuvent demander bien davantage que des quartiers dérivés. Cette fourchette n’inclut pas tous les locaux jamais montrés, tous les ponts détaillés, équipage animé, simulation complète ni VR ; l’effort d’un vaisseau intégral reste **inconnu** tant que sa portée et son plan ne sont pas fixés.

Le prochain jalon doit mesurer la qualité du premier module : si le gain des packs génériques est faible, concentrer le travail sur quelques pièces signature plutôt que multiplier les imports. Aucune réalisation de cette proposition n’est commencée pendant la mission documentaire.
