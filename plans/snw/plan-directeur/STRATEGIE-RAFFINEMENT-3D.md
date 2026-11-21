# Ad Astra · Stratégie de raffinement du rendu

**Décision de production.** Garder une visite jouable pendant toute la construction. Amener d’abord les locaux recensés au niveau de finition des quartiers de Pike. Pour la qualité supérieure, choisir un changement visible sur un parcours témoin, mesurer son effet, puis le déployer sur les occurrences compatibles. La propagation se décide par famille d’objets ou de surfaces. La validation se fait dans les pièces où le joueur les voit.

## 1. Donner à chaque information un propriétaire

| Information | Référence utilisée pour construire ou modifier la visite |
|---|---|
| Contour d’une pièce, altitude, seuil et raccord | Plan directeur dans le repère du vaisseau. La scène, la minicarte et les tests lisent les mêmes positions. |
| Fonction et silhouette du mobilier | Plan de production et photos identifiées par feuille ou page. Un emplacement déduit porte la mention « hypothèse » et peut être révisé. |
| Modèle partagé | Une définition stable par famille fonctionnelle, avec origine locale, orientation avant, dimensions, matériaux et points d’appui. Préférer une variante lorsqu’elle change la silhouette ou l’usage. |
| Objet posé | Un identifiant stable par occurrence, pont, pièce, modèle, pose locale, support et éventuelle variante. Une correction d’implantation s’applique à cette occurrence. |
| Circulation et interaction | Gabarit du personnage, volumes de collision, course de porte et points d’interaction vérifiés indépendamment du détail visuel. Revalider si le nouveau modèle déborde de l’enveloppe. |

Réutiliser le registre du pilote. Faire un essai de substitution sur les tabourets du bar avant de multiplier les variantes. Contrôler que chaque pied reste au sol, que les sièges regardent le bar et que le passage est libre, puis restaurer la version livrée. Un tabouret mieux modélisé doit pouvoir remplacer toute sa famille en une opération. Déplacer le poêle de Pike reste une correction locale. Les trois anciens plans de cuisine illustrent la limite de la mutualisation : lavage, préparation et cuisson peuvent partager leurs matériaux tout en gardant des équipements différents.

## 2. Définir une progression qui se voit

| Finition livrée | Ce que le joueur doit pouvoir constater | Critère de passage |
|---|---|---|
| Maquette jouable | Depuis la porte, la forme, les passages et le mobilier principal permettent de reconnaître la pièce. | Aller-retour en jeu, carte cohérente, supports jointifs, comparaison avec une référence. |
| Décor fidèle | Les silhouettes caractéristiques, proportions, matériaux et lumière rappellent le décor depuis les angles montrés dans la série. | Comparaison côte à côte sur poses fixes et au moins une vue latérale. L’amélioration reste visible à distance normale de jeu. |
| Finition rapprochée | À portée de main, on lit les commandes, les assemblages et les matières. Les éléments mobiles répondent correctement. | Gros plan en jeu, contrôle en mouvement et mesure de fluidité. Priorité aux objets que le joueur voit de près ou manipule. |

Les **préréglages graphiques du joueur** sont un autre axe. Fluide, Équilibré et Élevé pourront agir sur ombres, reflets, résolution de rendu et distance de détail. Ils conservent les mêmes pièces, passages et interactions. Étalonner leurs différences sur le PC cible avant de fixer une cible de performance. Une pièce peut ainsi être au stade « décor fidèle » sur les trois réglages.

## 3. Boucle de livraison par famille

1. **Choisir le gain.** Partir d’un défaut visible ou d’une référence précise. Prioriser ce qui gêne la marche et l’orientation, puis ce qui change fortement l’identité du décor, puis les améliorations perceptibles dans de nombreuses pièces. Reporter le détail peu visible.
2. **Conserver un avant.** Choisir le trajet turbolift–salon de Pike pour les matériaux chauds, l’ameublement et les transitions. Ajouter un contre-exemple pertinent, par exemple le pont 4 pour une fixation sur paroi courbe. Garder carte, pose de caméra, graine, réglages, résolution et version.
3. **Modifier au bon endroit.** Corriger l’implantation locale, la définition partagée, le matériau ou le profil d’éclairage selon la cause. Faire une seule comparaison interprétable à la fois. Une nouvelle famille très spécifique, comme le bar de Pike, peut rester propre à sa pièce.
4. **Essayer dans Unreal.** Traverser la porte dans les deux sens et longer les murs à hauteur d’œil. Mesurer au point le plus étroit, socle et saillies compris. Tester la carte et les interactions concernées. Comparer les mêmes vues avant/après et regarder effectivement les images. Sur le même trajet échauffé, relever le temps d’image médian et le 95e percentile. Le second révèle les ralentissements qui se perdent dans les FPS moyens.
5. **Propager progressivement.** Identifier les occurrences depuis le registre. Essayer d’abord le cas représentatif et le cas géométriquement difficile, puis appliquer aux occurrences compatibles. Contrôler automatiquement tous leurs appuis et dégagements. Examiner en jeu des extrêmes et des échecs, avec des vues latérales rejouables. Si une occurrence a une autre fonction ou un autre support, lui donner une variante.
6. **Accepter ou revenir en arrière.** Garder le changement si le gain se voit, si les trajets passent et si son coût graphique convient au réglage testé. En cas de régression, restaurer la définition précédente et conserver la pose défaillante comme test. Un petit commit par changement cohérent permet de revenir sur une famille sans défaire l’aménagement d’un pont.

## 4. Réduire le coût en tokens et en reprises

- **Un index partagé, un dossier court par lot.** L’index recense locaux prévus, intérieurs réellement construits, accès testés et lacunes. Pour chaque intervention, transmettre le périmètre, les identifiants concernés, une ou deux références pertinentes, les tests attendus et la dernière version jouable. Éviter de relire tous les épisodes, PDF et historiques de chat à chaque pièce.
- **Faire calculer les faits répétitifs.** Extraire du registre les occurrences touchées. Laisser les outils vérifier dimensions, appuis, collisions et chemins. Renvoyer au modèle les totaux, exceptions et chemins des preuves. Garder les journaux complets sur disque. Les vues fixes servent à comparer ; les parcours aléatoires servent à découvrir des défauts et conservent leur graine.
- **Budgéter l’attention visuelle.** Produire une planche des vues modifiées ; ouvrir à pleine taille les vues décisives, latérales et ambiguës. Rejouer d’abord le secteur touché, puis les correspondances et les tests étendus avant propagation. Une capture inchangée ou un journal identique ne mérite pas une nouvelle analyse.
- **Choisir l’effort selon la décision.** Un exécutant conserve la responsabilité du lot jusqu’au test. Confier la synthèse difficile à un raisonnement plus poussé lorsqu’il existe une contradiction entre sources, une modification transversale ou un échec persistant. Éviter les agents qui refont la même recherche et les messages de suivi sans changement.
- **Mesurer avant d’optimiser.** Consigner par lot les tokens lorsqu’ils sont disponibles, les essais en jeu, les reprises et les occurrences améliorées. Comparer deux lots de même nature. Une économie de tokens qui oblige à reconstruire la pièce au lot suivant est une perte. Aucun pourcentage d’économie n’est présumé.

## 5. Application aux prochains lots

Terminer la traversée autour du poêle et la cuisine du pont 5. Construire et éprouver le bureau de Pike derrière la porte rouge du pont 1. Croiser ensuite l’inventaire des 18 ponts avec la scène jouable. Une porte, un palier ou une surface réservée gardent leur propre état jusqu’à ce que l’intérieur existe et que l’aller-retour soit vérifié. Développer les locaux manquants par secteurs raccordés, en conservant le niveau actuel. Le premier investissement de finition supérieure portera sur une famille visible le long du trajet témoin, avec comparaison avant/après et coût mesuré avant généralisation.

À la fin d’un lot, garder un bilan court : **version jouable, changement visible, portée, tests exécutés, limites et prochain lot**. Les références et preuves restent accessibles par lien. Les captures lourdes et les caches restent sur le disque de travail.