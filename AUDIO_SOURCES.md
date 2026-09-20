# Audio intégré et régénérable

Les fichiers complets restent dans `sounds/sources/`. Godot ne lit que les
OGG préparés dans `godot/audio/generated/`. Le lien entre les deux est décrit
dans `sounds/audio_manifest.json` et produit par `prepare_audio.ps1`.

- `musique.mp3` devient `music.ogg`.
- `ambiance_1.mp3` devient `ambience_main.ogg` et peut être mixée séparément.
- `ambiance_2.mp3` devient `ambience_alt.ogg` et peut être mixée séparément.
- `door.mp3` fournit `door_open.ogg` (0,60–1,38 s) et `door_close.ogg`
  (2,36–3,55 s).
- `footsteps_1.mp3` fournit les deux pas alternés `footstep_01.ogg`
  (1,24–1,45 s) et `footstep_02.ogg` (1,96–2,44 s). Un gain indiqué dans le
  manifeste ne modifie que les copies Godot, jamais la source fournie.

Pour remplacer une source : déposer le nouveau fichier dans `sounds/sources/`,
ajuster son entrée dans `audio_manifest.json`, puis lancer
`prepare_audio.ps1`. Aucun script Godot ne doit être modifié.
