# AdAstra — direction visuelle verrouillée

Correction prioritaire du brief : les références de couloir guident désormais un sol gris perle clair (#CCCFC9, rugosité 0,32), et des murs ivoire neutre (#E9E7DF). Cela remplace le sol sombre #626968 et les anciens aplats. Le témoin doit présenter des arrondis géométriques visibles, des panneaux biseautés et deux sources dirigées avec ombres. La couche PBR procédurale à échelle réelle remplace la demande de cartes raster pour cette passe économique. Les deux captures du couloir et de l'accès suffisent à la revue ; pas de généralisation avant avis du propriétaire.

Date : 12 septembre 2026. Livrable de conception uniquement ; la scène n'est pas modifiée. Ce document fixe la prochaine passe visuelle et remplace les choix esthétiques antérieurs du pilote lorsqu'ils divergent. PILOT.md reste le compte rendu de ce qui est effectivement intégré.

## Intention et références

Un intérieur clair, calme et soigné : grandes surfaces ivoire, joints précis, contours doux, sol gris satiné, lumière blanche enveloppante avec une chaleur légère. La sophistication vient des raccords et des reflets mesurés. Aucune accumulation de motifs techniques.

Références directement observées : couloir_1.png, couloir_2.png, cabine_1.png de « Avancer sans Work », ainsi que les captures déjà jointes à cette tâche. Les couloirs montrent des cadres arrondis, des inserts sombres localisés, une ligne lumineuse à hauteur intermédiaire et un sol plus clair et réfléchissant que le pilote. La cabine associe ivoire, graphite et bordeaux dans une lumière plus intime. Ces observations guident les choix ; les valeurs ci-dessous sont des réglages de conception, pas des mesures tirées des images.

Comparaison avec pilot_01_couloir.png : supprimer dans le prochain témoin le bandeau brun, les aplats jaunâtres, le sol presque noir et l'impression de boîtiers lumineux suspendus. Garder la sobriété et la lisibilité du passage.

## Matériaux définitifs pour le témoin

Couleurs de base sRGB ; rugosité et métal compris entre 0 et 1.

| Surface | Couleur | Rugosité cible | Métal | Traitement |
|---|---|---|---|---|
| Parois et grands cadres | #E3DFD5 | 0.60 | 0 | Composite ivoire satiné, microrelief presque imperceptible |
| Plafond | #EAE8E0 | 0.75 | 0 | Blanc cassé mat, panneaux larges |
| Sol du couloir | #626968 | 0.40 | 0 | Gris moyen-foncé satiné, grain très fin, reflets diffus |
| Inserts et plinthes | #343D40 | 0.52 | 0 | Graphite neutre, surfaces limitées |
| Petits trims métalliques | #A2A5A3 | 0.36 | 1 | Aluminium satiné sans rayures visibles |
| Accent facultatif ultérieur | #803832 | 0.55 | 0 | Bordeaux désaturé ; absent du premier témoin |

Sol : abandonner le gros motif caoutchouc comme signature du couloir ; conserver les assets existants archivés. Créer des cartes originales et raccordables de couleur, rugosité et normale, à l'échelle du mètre, 1K par défaut. Variation de rugosité limitée à ±0.04, sans saleté ni usure. Ni métal sur les peintures, ni ombres ou reflets peints dans la couleur. Le relief reste invisible à distance normale ; les joints principaux et chanfreins sont géométriques.

## Bibliothèque originale et composition des 5 m

- Un panneau mural ivoire : largeur nominale 1 m, ajustement au bord des ouvertures, joint de 3 mm, chanfrein de 4 mm. Grandes faces calmes ; aucun boulon apparent. Le découpage suit les surfaces disponibles, jamais au travers d'un accès.
- Un soubassement ivoire jusqu'à 0.85 m ; une gorge lumineuse horizontale de 25 mm à environ 1 m, interrompue aux accès. Courts inserts graphite sous cette ligne, limités à un par travée pleine ; pas de bande sombre continue.
- Un cadre d'accès ivoire à double retrait : largeur de face 90 mm, coins extérieurs de rayon 100 mm, filet graphite de 8 mm. Conserver intégralement le rectangle libre actuel, y compris ses coins ; placer l'arrondi et l'épaisseur autour du passage, jamais dedans. Aucun seuil, vantail ou nouveau portique transversal.
- Un plafond à grands panneaux mats et une gorge longitudinale de chaque côté. Diffuseur opalin de 40 mm dans un logement de 60 mm, intégré visuellement au raccord mur/plafond. Supprimer les luminaires du pilote remplacés pour éviter leur superposition.
- Un panneau technique fermé de 180 × 300 mm, à coins arrondis, près de l'accès existant. Un unique petit voyant blanc ; ni écran inventé ni fausse fonction de pièce.

Les parements doivent remplacer la finition visible dans l'enveloppe disponible, sans réduire la largeur ou hauteur utile. Si un relief ne tient pas, utiliser un joint de surface et une normale subtile ; ne jamais décaler une cloison pour faire rentrer le décor. Pas de nouvelle cloison de séparation : seul le cadre réutilisable habille l'accès existant.

## Lumière et déclinaison

Couloir : blanc neutre légèrement chaud, cible artistique 3800 K pour les diffuseurs et 3200 K pour le remplissage indirect discret. Le blanc doit rester ivoire clair, jamais jaune. Les diffuseurs ont une surface visible et une source qui éclaire réellement ; l'émission seule ne suffit pas. Conserver Compatibility, sans dépendance au bloom ou à une illumination globale. Réutiliser le budget de deux sources à ombres du pilote ; sonde locale pour des reflets doux. Les parois doivent présenter un dégradé léger, sans taches ni fuites.

Après validation du témoin seulement : cabines avec la même famille de panneaux, lumière cible 3000–3200 K et une touche bordeaux sur un élément existant ; cockpit avec lumière neutre 4000 K et graphite autour de la baie pour préserver la vue ; hangar avec le même ivoire et un sol plus mat (0.65). Ces déclinaisons n'autorisent pas de nouveau mobilier, d'ouverture ou de fonction.

## Exécution et validation bornées

Prochaine passe : produire ce petit kit paramétrique original et les matériaux dans une couche d'habillage Godot indépendante du GLB, puis l'appliquer uniquement au témoin existant X=18..23 m, Z Godot=8..10 m et à son accès U1. Préserver les 62 m, six cabines, plans, collisions et commandes FPS. Aucun téléchargement de pack ou recherche supplémentaire requis pour cette direction.

Conserver le témoin précédent pour comparaison. Lancer Godot et capturer depuis les mêmes positions : vue longitudinale à hauteur d'œil, accès de trois quarts, raccord mur/plafond et gros plan du sol. Juger les arrondis, la neutralité des blancs, l'échelle des joints, la douceur des reflets et la visibilité des sources. Rejeter une passe encore plate, jaunâtre, trop sombre ou encombrée ; corriger les défauts observés et recapturer.

Vérifier le passage FPS, l'accès U1, l'absence de scintillement et d'erreur d'import. Comparer les temps d'image au témoin précédent aux mêmes réglages ; ne pas présenter 60 FPS sous VSync comme une mesure de marge GPU. Montrer le témoin au propriétaire avant généralisation. Salles de bain, détails de cockpit, portes arrière, extérieur et mobilier restent hors de cette passe.

## Économie de travail

Une seule direction, un seul kit, une seule zone. Pas de variantes concurrentes, pas de concept art généré, pas de relance de la recherche d'assets. La prochaine implémentation suit ce document ; les itérations portent sur les captures et les défauts constatés, pas sur une nouvelle recherche de style.
