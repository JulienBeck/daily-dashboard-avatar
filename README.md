# daily-dashboard-avatar

3D-Spielfiguren für das [daily-dashboard](https://github.com/JulienBeck/daily-dashboard): je
Körperbau ein GLB mit Skelett, Idle-Animation und allen Gegenständen des Katalogs, dazu ein Icon
je Gegenstand. Gebaut in Blender, ausgeliefert als eigenes nginx-Image.

## Was hier liegt

| Pfad | Inhalt |
|---|---|
| `blender/build.py` | Blender-Skript: Grundkörper aus MPFB2 (MakeHuman), Kleidung als Schale über der Haut, Rüstung und Waffen als eigene Meshes am Skelett, Idle-Animation, Export, Icons |
| `build.sh` | baut beide Körper und die Icons, komprimiert die GLBs mit gltfpack, schreibt nach `public/` |
| `public/male.glb`, `public/female.glb` | die ausgelieferten Modelle (Meshopt-komprimiert, je gut 1 MB) |
| `public/icons/<id>.png` | ein Icon je Gegenstand, 128 px, transparenter Hintergrund |
| `Dockerfile`, `nginx.conf` | nginx auf Port 8080, liefert `public/` unter `/avatar/` aus, `/healthz` für die Probe |

Die gebauten Dateien sind eingecheckt: das Image braucht kein Blender, nur `public/`.

## Was das Dashboard erwartet

| Erwartung | Woran sie hängt |
|---|---|
| Objekte heißen `item_<id>` | `wardrobe.ts` blendet sie nach der Ausrüstung ein und aus |
| Teile `body`, `eyes`, `eyebrows`, `eyelashes`, `hair` | `hair` verschwindet, sobald etwas auf dem Kopf sitzt |
| Materialien `<id>.primary` / `<id>.secondary` | färbt das Dashboard zur Laufzeit aus dem Katalog |
| Animation `idle` | spielt in Schleife, steht bei reduzierter Bewegung |
| Meshopt-Kompression | `scene.ts` setzt den `MeshoptDecoder` |

Ein neuer Gegenstand im Katalog braucht hier eine Bauanleitung in `Wardrobe.BUILDERS` und einen
neuen Lauf. Bis dahin zeigt das Dashboard für ihn weder Mesh noch Icon, alles andere geht weiter.

## Neu bauen

```sh
npm install
BLENDER=/pfad/zu/blender DASHBOARD=../daily-dashboard ./build.sh
```

| Variable | Vorgabe | Wofür |
|---|---|---|
| `BLENDER` | `blender` | Blender 4.5 LTS |
| `DASHBOARD` | `../daily-dashboard` | Checkout des Dashboards; `src/shared/avatar.ts` dort ist der Katalog |

Gebraucht werden Blender 4.5 LTS, die Extension MPFB2 und das Asset-Pack
„makehuman_system_assets“ (Haut, Augen, Haare) im MPFB-Datenordner. Ein Lauf dauert einige
Minuten, die Icons rendert Cycles auf der CPU.

## Ausliefern

Das Image baut `daily-dashboard-kube` aus diesem Repository, so wie die beiden Images des
Dashboards. Im Cluster leitet die nginx des Dashboards `/avatar/` an diesen Dienst weiter
(`AVATAR_UPSTREAM`). Für den Browser liegt damit alles unter derselben Adresse, also ohne CORS
und hinter derselben Basic Auth.

Lokal startet `docker compose up` im Dashboard dieses Image mit, wenn das Repository daneben liegt.

## Lizenzen

Der Code von MPFB steht unter GPL, seine Assets und die daraus erzeugten Modelle unter CC0.
