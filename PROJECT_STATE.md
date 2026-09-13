# AdAstra — habillage intérieur 06

## Interface de base

Le lancement s'effectue en fenêtre maximisée, sans déformation grâce à l'adaptation de l'interface à l'écran. F11 bascule en plein écran puis en fenêtre. Une page d'accueil minimale mène à l'exploration. Pendant la marche, seul le nom de zone et un point central discret restent visibles ; l'aide aux commandes disparaît après quelques secondes. Échap ouvre le menu pause, libère la souris et propose Reprendre, Aide / Commandes, Plein écran / Fenêtre et Quitter. Reprendre recapture la souris. Aucune scène 3D, géométrie, collision ou commande de déplacement n'a été modifiée.

Double-cliquer LANCER.cmd. ZQSD/WASD + souris ; cliquer pour capturer la souris ; Échap pour la libérer ; F2 extérieur ; R cockpit ; F10 quitter.

## Témoin visuel actuel

Dernière correction géométrique : cadres, inserts, diffuseurs et soubassements utilisent maintenant les mêmes plans de face intérieure. Les reliefs sont construits depuis le mur vers le couloir et le cadre est fermé jusqu'à son support. Trois angles rasants régénérés et inspectés après lancement ; aucun cache visuel ponctuel ajouté.

Correction finale limitée au témoin : sol ivoire satiné à joints gris fins, graphite adouci, inserts interrompus avant U1 et cadre aminci. Lancement et captures axiale, oblique et rapprochée de l'accès vérifiés. Le reste du couloir demeure volontairement hors de cette passe.

Dernier contrôle : retours du cadre fermés jusqu'au mur, diffuseurs clairement lumineux et biais d'ombres corrigé pour supprimer les fortes stries. Trois captures régénérées et inspectées après lancement réel. Architecture et collisions inchangées.

13 septembre : finition consolidée, groupes de modules séparés, plinthes régulières, plafond en quatre travées, luminaires symétriques intégrés, cadre au premier plan du raccord, suppression visuelle du marquage rouge au seuil, sol moyen satiné selon le dernier brief. 105 contrôles réussis en lancement avec fenêtre. Trois captures actualisées dont pilot_03_raccord.png. Voir MODULAR_KIT.md pour l'état actuel ; les descriptions de passes précédentes ci-dessous sont historiques.

Correction du témoin : sol gris perle à joints fins et matériau PBR procédural, panneaux biseautés aux coins arrondis, cadre courbe visible, deux spots avec ombres. Le détail isolé du mur et le seuil décoratif ambigu ont été supprimés ; le raccord plafond/mur est maintenant composé de fascias et de lignes lumineuses modulaires. Captures actualisées : pilot_01_couloir.png et pilot_02_acces.png. Voir MODULAR_KIT.md. La teinte graphite du sol et le cadre chanfreiné mentionnés ci-dessous décrivent l'ancienne passe. Lancement vérifié ; pas de tests complets supplémentaires. Reflets et éclairage restent provisoires.

Le seul développement visuel récent est le couloir témoin de 5 m, X=18..23 m. `godot/pilot.gd` construit maintenant un kit original de panneaux ivoire, sol graphite satiné, gorges lumineuses intégrées, cadre chanfreiné et panneau technique discret. Il remplace l'ancien essai fondé sur des packs dans cette zone seulement. Voir `PILOT.md` et `VISUAL_DIRECTION.md`. Aucune généralisation ni modification architecturale n'est autorisée avant validation du témoin.

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

## Passe coque du 13 septembre 2026 — locale, non validée pour publication
- Suppression de l'override métallique intérieur/extérieur ; matériaux par surface dans le GLB.
- Proue : peau de 0,35 m, vitrages de 0,025 m en retrait, normales corrigées et premières surfaces de raccord.
- Cylindre : tessellation accrue et lissage. Parois diagonales existantes prolongées au toit du hangar.
- Godot lancé réellement : aucune erreur dans les journaux, 56 maillages de collision ; contrôle ponctuel des six ouvertures de cabines libre (rayons, pas parcours FPS complet).
- Plans, paramètres dimensionnels, cabines et script du joueur inchangés. Les collisions structurelles sont régénérées avec la géométrie corrigée.
- Deux générations/lancements : le second corrige des normales inversées observées sur les premières captures. Trois fichiers finaux : exterior_metal.png, cockpit.png, hangar.png.
- Résultat intérieur amélioré ; extérieur encore trop segmenté, raccords et liserés clairs insuffisamment intégrés. Critère global de coque cohérente NON atteint. Aucun commit/push pour ne pas publier comme validé.
- Portes arrière et finitions restent provisoires.

## Coque intégrée — première référence artistique

- Enveloppe extérieure continue générée par sections paramétriques : raccords courbes proue/cylindre, cylindre/bande et bande/hangar. Pas de nouvel espace intérieur.
- Les anciennes faces extérieures sont masquées par surface dans Godot ; les parois intérieures et les collisions structurelles restent présentes. La nouvelle peau extérieure ne crée pas de collisions dans les circulations.
- Le panneau vertical au-dessus de l'entrée du hangar est remplacé par le raccord de plafond progressif convenu ; seule sa géométrie et sa collision haute évoluent.
- Plans sources, blockout.json, paramètres des six cabines, fenêtres, mobilier, pilote FPS et UI inchangés par cette passe. Longueur nominale 62 m conservée.
- Validation Godot 4.5.2 Compatibility : import et lancement sans erreur, 56 maillages structurels de collision, six ouvertures libres au contrôle par rayons. Pas de parcours FPS complet ni campagne de performances.
- Deux générations Blender (correction d'un chevauchement au hangar), puis réglage des ombres extérieures et cadrage final sans régénération supplémentaire. Trois captures finales : exterior_metal.png, cockpit.png, hangar.png.
- L'enveloppe extérieure ne reçoit pas les ombres des anciens volumes : compromis de blockout pour éviter leur silhouette sur les raccords nouveaux. L'éclairage intérieur est conservé.
- Résultat retenu pour cette passe : continuité de la coque et fenêtres conservées ; rendu métallique, petits raccords, panneaux détaillés et portes arrière restent provisoires. La référence artistique reste une direction, pas un rendu final reproduit à l'identique.
