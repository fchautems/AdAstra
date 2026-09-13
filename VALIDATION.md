# Validation — intérieur 02

## Première itération exécutée
Génération Blender, import GLB, lancement graphique Godot sur GTX 1070 Ti. Captures à hauteur d'œil du couloir, des accès, pièces, cabine, cockpit, hangar et extérieur.

Observation : circulation bien délimitée et plafond dégagé ; accès lisibles. Défauts repérés : faces superposées sur les jambages, cabines encore trop profondes et vides pour apprécier l'échelle, cadrage latéral montrant surtout une paroi.

## Corrections puis nouveau lancement
- Reconstruction des jambages et linteaux avec volumes adjacents sans superposition dans les ouvertures.
- Profondeur utile des cabines ramenée à environ 4,3 m.
- Ajout de masses simples de couchette, tablette, banquette et table, hors des parcours.
- Baies encadrées et entrée du hangar rehaussée.
- Orientation des panneaux corrigée ; petite pénétration de paroi dans la coque avant supprimée.
- Accès et pièces recadrés ; captures finales sans interface.

Nouvelle génération et exécution Godot, observation des nouvelles captures : disparition des stries des encadrements ; largeur de circulation régulière et hauteur confortable ; limites de pièces et accès traversants identifiables ; repères d'échelle perceptibles dans les cabines et pièces. Le hangar se distingue par sa hauteur. Le rendu reste un blockout en aplats.

## Résultat final
**77 contrôles réussis**, résultat machine dans test-results.json.

Les parcours traversent les six pièces centrales, les six cabines, les galeries, les vestibules, le cockpit et le hangar. Les rayons mesurent 2,60 m libres pour le couloir, 3 m de plafond et 1,50 × 2,45 m pour les ouvertures. Contrôles du contact au sol, de l'arrêt contre une cloison en courant, des murs arrière et de cabine, du plafond, de W/Z/A/Q/S/D, de la souris, d'Échap et du changement de caméra.

Les événements sont injectés dans le moteur ; les parcours sont automatisés. Cela ne remplace pas un essai humain prolongé du confort. Le jugement visuel repose sur les captures réelles à hauteur du joueur.

Les usages des pièces, proportions de coque et aménagements restent provisoires. Les fenêtres sont opaques ; aucune porte arrière détaillée ni mécanique de rotation.

