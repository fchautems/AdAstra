# Méthode, couverture et vérifications

Date : **2026-11-17**. Recherche extensive et bornée, sans prétendre couvrir tout Internet ni prouver l’inexistence d’une ressource privée, non indexée ou future. Arrêt des requêtes lorsque les nouvelles passes renvoyaient surtout les mêmes sources ou des projets hors sujet.

## Points de contrôle

| Phase | Travail réalisé | Résultat / limite |
|---|---|---|
| 1. Audit | Clone du véritable AdAstra, lecture des états, code, scripts Blender, GLB et licences ; Brain consulté par connecteur | État réel plus avancé que Brain ; géométrie originale conservée |
| 2. Recherche large | Plusieurs passes de recherche web et GitHub, deux moteurs, termes SNW et versions secondaires, projets anciens/arrêtés | Sources de production prioritaires identifiées ; aucun vaisseau SNW complet réutilisable validé |
| 3. Inspection | 8 clones de projets pertinents ou plausibles, fichiers ciblés lus ; 2 modèles Sketchfab via API publique et aperçus | Snapshots et chemins conservés ; pas de test d’intégration des candidats |
| 4. Tri | Comparaison fidélité, formats, dépendances, licence et coût d’adaptation | C01/C02 ciblés, kits génériques en appoint ; Stage 9 et sources de jeu exclus |
| 5. Documentation | Catalogue structuré, page HTML, audit, matrice des 12 pièces, plans, architecture et témoin proposé | Aucun code fonctionnel, asset ou plan du jeu modifié |
| 6. Vérification | Contrôles JSON/HTML, préservation par empreintes, contrôle de liens et présence GitHub | Résultats détaillés dans `verification.json` et `liens.json` ; erreurs d’accès distinguées des liens confirmés morts |
| 7. Recommandation | Godot + Blender, approche hybride et zone emblématique limitée | Relevé métrique et validation visuelle à faire avant reconstruction |

## Couverture de recherche

Les exemples de requêtes sont conservés pour éviter une reprise identique. Une recherche sans résultat exploitable n’est pas transformée en certificat d’absence.

| Domaine | Requêtes / pistes explorées | Conclusion utile |
|---|---|---|
| GitHub | `star trek enterprise interior`, `star trek simulator`, `star trek unreal`, `enterprise bridge unity`, `enterprise 3d reconstruction`, dépôts de marche/interactions/génération | Huit dépôts inspectés sur fichiers. Recherche par intitulé corrigée par examen du contenu ; faux positifs éliminés |
| GitLab | `site:gitlab.com "star trek"`, variantes interior/godot/unity ; ESR Super Star Trek | Jeu textuel hors besoin 3D ; pas de candidat SNW exploitable validé. Contenu direct partiellement inaccessible |
| Godot Asset Library | Contrôleurs FPS et fiche 2087 | Ancienne fiche dépréciée ; v2 GitHub préférée pour comparaison |
| Unity | NetTrekUnity et recherches Enterprise/bridge | Port C# nécessaire ; licences et assets de mods ne permettent pas une reprise simple |
| Unreal / visites | Stage 9, Enterprise-D Construction Project, Roddenberry, portfolio Leech, packs multi-moteurs | Bonnes références de résultat ; aucune source SNW complète et réutilisable démontrée |
| Sketchfab | Enterprise SNW WIP, bridge, DSC bridge WIP, passerelles et collections | Deux modèles vérifiés par API et aperçu ; autres pistes clairement marquées non vérifiées sur fichiers |
| CGTrader | SNW/interior, Enterprise full interior, refit concept, navettes et props | « Full interior » identifié comme Enterprise-A et très lourd ; aucun pack SNW complet validé |
| TurboSquid | Enterprise / bridge / SNW | Enterprise-E : autre génération, lourdeur et restriction éditoriale ; écarté |
| BlenderKit | Requêtes ciblées `site:blenderkit.com "star trek"`, `"spaceship" "interior"`, `"spaceship interior"` sur deux moteurs | Aucun candidat SNW précis suffisamment documenté obtenu ; bibliothèque intégrale non inspectée |
| OpenGameArt | Space Station Kit, Modular Space Kit, Modular Sci-Fi MegaKit, Sci-Fi Essentials | Kits CC0 génériques ; blocage robots en accès direct. Origines Kenney/Quaternius et fichiers locaux utilisés comme meilleures preuves |
| Fab | Spaceship Interior, Modular Spaceship, Big Modular SciFi, kit 35 assets | Fiche détaillée de 35 modèles consultée ; prix/licence non exposés, pas de test fichier. Autres résultats servent de comparaison, sans achat |
| Communautés / archives | TrekBBS, Frogland, Cygnus-X1, Trekmeshes, Pundus, discussions anciennes | Sources de plans et modèles anciennes conservées comme pistes ; vérifier auteur, génération et permissions par élément |
| Production | ADG 254 p., John Allen, Ryan Dening, North Front, StarTrek.com, ASC | Meilleur socle pour une reconstruction SNW fidèle ; pas d’autorisation de republier leurs images ou leurs fichiers |
| Photographies / épisodes | Galerie officielle pilote, EAS avec photos promotionnelles, pages de production et références de saison | Aperçus vérifiés pour plusieurs pièces. Pas de collecte de captures d’épisodes ni de téléchargement de vidéo protégée |

Certaines requêtes ont renvoyé des agrégateurs de modèles à provenance incertaine : ils ne sont pas retenus comme fournisseurs. Les outils d’extraction de jeux remontés pendant la recherche ne sont pas utilisés. La qualité de l’inventaire repose sur le niveau de preuve indiqué dans chaque fiche, pas sur le nombre de liens.

## Niveaux de vérification

| Mention | Ce qu’elle signifie |
|---|---|
| Fichier local inspecté | Le contenu ou les métadonnées du fichier ont été examinés dans le snapshot indiqué |
| API publique consultée | Métadonnées du service obtenues directement ; ne prouve pas le contenu de l’archive téléchargeable |
| Page consultée | Contenu de la page lu par l’outil web ; annonces d’auteur/vendeur attribuées comme telles |
| Index consulté / non vérifié | Résultat de recherche disponible, page ou fichiers non vérifiables ; aucune promesse d’intégration |
| Import / chargement limité | Contrôle réellement exécuté sur copie isolée, version et limites précisées |
| Réutilisable sous conditions | La fonction et la licence sont identifiées ; validation d’intégration toujours nécessaire |

## Contrôle des liens

`liens.json` contient la sonde HTTP datée des URL principales et des aperçus, avec statut ou erreur. Les refus 403/robots, 429 et timeouts ne prouvent pas un lien mort. L’accès par outil de recherche et l’accès par HTTP direct peuvent donner des résultats différents ; les fiches indiquent le niveau réellement obtenu. Les fragments PDF `#page=` sont des positions de lecteur, pas des fichiers différents.

Cas connus : PDF ADG refusé par l’extracteur web pour sa taille mais téléchargé légalement depuis sa source et inspecté temporairement ; pages/API ArtStation et CDN Roddenberry refusant certaines requêtes ; Frogland 502 ; OpenGameArt robots. Aucune tentative de contourner une connexion ou un contrôle d’accès.

## Contrôles du livrable

- JSON valides et identifiants uniques ; toutes les fiches comportent formats, droits, prix, fidélité, maintenance, inspection et réemploi.
- Douze familles de pièces présentes, liens internes et ancres HTML contrôlés, pas de dépendance JavaScript distante, aucune requête `fetch()` locale nécessaire.
- Le lancement de Chromium headless échoue sur une restriction système (`socket() failed: Operation not permitted`) ; le lancement natif ne fournit aucune fenêtre exploitable. Aucun rendu visuel ordinateur/téléphone n’est donc déclaré vérifié. Le JavaScript réel est vérifié dans Node avec les données DOM extraites du HTML : recherche, filtre et remise à zéro. Ce contrôle ne remplace pas un essai en navigateur. Détail dans `verification.json`.
- Empreintes SHA-256 de tous les fichiers suivis d’origine hors documents d’état autorisés comparées avant publication. Un diff de documentation seul est requis.
- Contrôle après écriture distante : présence et contenu des livrables vérifiés par GitHub / nouveau fetch Git. Les résultats de publication sont enregistrés dans l’état du projet et le rapport final.

Les scripts temporaires d’audit, les clones tiers, le PDF ADG, les images téléchargées pour inspection et les caches Godot ne sont **pas** ajoutés au dépôt. Les données publiées sont nos synthèses, URL, observations, empreintes et métadonnées nécessaires. Le HTML référence des images distantes et affiche une alternative si elles échouent ; ce n’est pas une archive hors ligne des œuvres protégées.

## Limites restantes et critères de reprise

Formats exacts des archives Sketchfab, contenu des packs payants, droits spécifiques Star Trek, dimensions lisibles des plans et répartition complète des ponts restent à vérifier. Aucune cote incertaine n’a été complétée par une valeur prétendument officielle.

Avant de réaliser la zone témoin : figer les références de saison, relever les cotes de quelques feuilles, confirmer le contrat des accès, puis intégrer les seuls composants nécessaires dans une scène distincte. Toute extension au vaisseau complet doit suivre un graphe de circulation sourcé et un budget mesuré sur la machine cible.
