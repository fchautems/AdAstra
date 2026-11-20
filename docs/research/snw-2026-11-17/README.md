# Mission AdAstra — base documentaire Enterprise SNW

Date : **2026-11-17**. Périmètre : audit, recherche et préparation. Aucune reconstruction, modification du jeu, régénération Blender, modification de plan ou acquisition payante.

## Résultat à retenir

**Conserver Godot 4 + Blender, réutiliser l’application actuelle et reconstruire uniquement les éléments visuels SNW qui manquent.** Aucun intérieur SNW complet avec fichiers accessibles, provenance et licence suffisamment établies n’a été identifié dans les recherches menées. Cela ne prouve pas qu’il n’en existe aucun.

Le meilleur gain est documentaire : le [dossier de production ADG](https://assets.adg.org/media/submissions/2022-10-17_14-08-24/Strange_New_Worlds_s1_ep101_ADG_Awards_Submission_20221017_v01.pdf), les portfolios de production et les reconstructions Roddenberry permettent de partir de références précises. Les modules de navigation et d’interaction évitent aussi de repartir de zéro.

## Lire et utiliser

| Document | Contenu |
|---|---|
| [catalogue.html](catalogue.html) | Catalogue visuel par pièce, filtres, comparaison des ressources et liens de plans |
| [CATALOGUE_RESSOURCES.md](CATALOGUE_RESSOURCES.md) | Fiches complètes : URL, formats, licences, prix, fidélité, maintenance, réemploi et niveau d’inspection |
| [ressources.json](ressources.json) | Inventaire structuré, exploitable pour la suite |
| [AUDIT_EXISTANT.md](AUDIT_EXISTANT.md) | État constaté dans AdAstra et écarts avec Brain |
| [CODE_REUTILISABLE.md](CODE_REUTILISABLE.md) | Inspection des dépôts et sélection de modules précis |
| [PIECES_ET_PLANS.md](PIECES_ET_PLANS.md) | Les 12 familles de pièces, plans, accès, dimensions connues ou inconnues et contradictions |
| [INVENTAIRE-LOCAUX-ET-PONTS.md](INVENTAIRE-LOCAUX-ET-PONTS.md) | Inventaire des locaux des saisons 1 à 4, ponts documentés, sources et question du pont 2 |
| [QUARTIERS-PIKE-PONT-5.md](QUARTIERS-PIKE-PONT-5.md) | Description du décor des quartiers de Pike, pièce par pièce, et limites documentaires |
| [INFIRMERIE-PONT-4.md](INFIRMERIE-PONT-4.md) | Relevé horodaté, sources du décor médical et implications pour le raccord au turbolift |
| [ARCHITECTURE_ET_PREMIERE_ZONE.md](ARCHITECTURE_ET_PREMIERE_ZONE.md) | Architecture proposée, comparaison des stratégies, charge et critères du premier témoin |
| [METHODE_ET_VERIFICATIONS.md](METHODE_ET_VERIFICATIONS.md) | Couverture des recherches, limites et contrôles réellement effectués |
| [verification.json](verification.json) | Résultats automatiques de cohérence et de préservation des fichiers |
| [evidence.json](evidence.json) | Empreintes, snapshots et inventaire des GLB existants ; aucune copie de ressource protégée |

Ouvrir `catalogue.html` par double-clic après récupération du dépôt. Le texte, les filtres et les index fonctionnent sans serveur et hors ligne. Les aperçus distants nécessitent Internet ; une source refusant l’affichage affiche un remplacement explicite et reste accessible par son lien. GitHub affiche le code HTML : il faut ouvrir le fichier local pour le consulter comme page.

## Références visuelles par décor

Dans *What Is Starfleet?* (saison 3, épisode 7), le reportage tourné à bord fournit plusieurs points de vue sur un même décor. Les vues ci-dessous servent à comparer les volumes aux plans de production et à choisir les détails à vérifier. [Récapitulatif officiel de l’épisode](https://www.startrek.com/news/recap-307-what-is-starfleet-strange-new-worlds)

| Décor | Vue à repérer | Usage pour le plan |
|---|---|---|
| Infirmerie | Plongée portant le libellé *Sickbay* | Repérer la disposition des lits, des îlots et des allées. Recouper l’emprise avec les feuilles S04. |
| Infirmerie | Chapel et M’Benga autour d’un biolit, puis M’Benga vu le long de la salle | Comparer les travées, les dégagements et les retombées de plafond sous deux angles. |
| Couloir | Vue dans l’axe vers une porte rouge, au début du reportage | Comparer les encadrements, la section du couloir et les portes. Pour le raccord au pont 4, suivre les séquences dédiées de S1E7 et S2E6. |
| Passerelle | Vue large du poste de commandement et des consoles | Relire l’organisation autour de l’espace central et confronter les circulations au plan de passerelle. |
| Coque | Vue extérieure oblique et schéma du vaisseau sur un écran de bord | Comparer la silhouette de la soucoupe et la position relative de la coque secondaire et des nacelles. Relever les cotes dans une vue orthographique calée. |

Pour l’infirmerie, commencer par les trois angles intérieurs et les feuilles S04. Les questions encore ouvertes concernent l’échelle du décor et la continuité du trajet entre le palier et la porte. [Fiche de l’infirmerie et sources des accès](INFIRMERIE-PONT-4.md)

## Sélection prioritaire

| Besoin | Choix | Conséquence |
|---|---|---|
| Apparence et proportions locales SNW | P01 ADG, P02 John Allen, P03–P07 production | Relever les dimensions sur les feuilles, recouper les variantes avec le décor final |
| Comparaison immersive | P08 Roddenberry, P09–P14 Richard Leech | Références visuelles ; fichiers et permissions de reprise non obtenus |
| Marches de la passerelle | C01 Majikayo | Adapter un module existant ; préserver la caméra et les commandes actuelles |
| Consoles et boutons | C02 snddude | Petit composant MIT ; portabilité sur la version Godot choisie à vérifier |
| Accessoires génériques | M07/M08/M13/M14 déjà présents ou CC0 | Réemploi sélectif ; les formes caractéristiques SNW restent spécifiques |
| Assemblage | Générateur existant + contrat de connecteurs inspiré de C04 | Disposition déterministe fondée sur les références ; pas de donjon aléatoire |

## Limites qui changent une décision

- Les plans actuels d’AdAstra décrivent un vaisseau original de **62 m**. Ils sont conservés et ne peuvent pas servir de plan global de l’Enterprise.
- Les plans de plateau montrent les décors de tournage, parfois répartis dans plusieurs bâtiments. Ils ne prouvent pas que ces pièces sont voisines à bord.
- Aucun placement métrique complet des 12 familles de pièces dans la coque n’est validé. Plusieurs dimensions restent **inconnues** ; aucune estimation n’est présentée comme officielle.
- Stage 9 interdit explicitement la réutilisation de ses assets. Les fichiers annoncés par certains projets ne figurent pas dans leur dépôt. Les deux obstacles sont documentés, pas contournés.
- Les annonces de vendeurs ont été comparées, sans achat ni test d’import des packs payants. Les droits sur un modèle fan ne valent pas autorisation globale sur Star Trek.
- Import et chargement d’une copie du projet existant vérifiés sous Godot Linux 4.6.3 ; avertissements de ressources à la fermeture. Aucun benchmark Windows/GTX 1070, jugement de rendu final ou nouveau parcours complet n’est revendiqué.

## Prochaine étape proposée

Valider le dossier de référence d’un **secteur arrière de passerelle, de son accès turbolift et d’un petit couloir de raccord explicitement hypothétique**. Ensuite seulement, lancer sa réalisation dans des scènes SNW séparées, avec les critères mesurables du document d’architecture. Aucune de ces scènes n’est créée durant cette mission.