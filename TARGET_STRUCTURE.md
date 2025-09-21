```markdown
# TARGET_STRUCTURE.md
**Rolle:** Lead-Entwickler (Agentur) / Technischer Architekt  
**Ziel:** Fehlerfreie Umsetzung der nächsten Iteration anhand klarer Struktur, präziser DIFF-Hunks und Akzeptanzkriterien – auf Basis der aktuell gelieferten `index.html`.

---

## 0) Kurzüberblick (Was ändert sich)
1. **Live-Box bleibt** und ist Benchmark.  
2. **Status → Bereich** in Ausgabe umstellen  
   - Live-Box-Metazeile neu: **`{theme} · {region} · {langes Datum}`**  
   - Karten-Meta: **Status-Pill entfernen**, **Bereich-Pill (= Thema) anzeigen**.  
3. **Agenda (Entwicklungsphase)**: „Nächste Termine in Brugg“ auf **genau 1 Eintrag** begrenzen; später via Maske/JSON beliebig erweiterbar.  
4. **Chips-Zeile**: Auf Desktop **eine** Zeile ohne Umbruch, auf Mobile horizontal scrollen (Snap).  
5. **Kein Umbau der Datenstruktur** nötig (noch `DATA{}` inline). Späterer Wechsel auf `content.json` vorbereitet.

---

## 1) Empfohlene Baumstruktur (Repository)

> Minimal-invasiv, merge-freundlich. Wenn ihr vorerst One-File bleiben wollt, nutzt die Marker aus Abschnitt 2.

```

/                     # Repo-Root
├─ public/
│  ├─ index.html      # Einstieg (bleibt Referenzdatei)
│  └─ assets/         # Bilder/Logos/Placeholders
├─ src/
│  ├─ css/
│  │  ├─ base.css     # Reset/Basis, Typografie, Farben, Utilities
│  │  ├─ layout.css   # Header, Hero, Grid, Footer
│  │  └─ components.css # Chips, Cards, Live-Box, Agenda
│  ├─ js/
│  │  ├─ helpers.js   # el(), pad(), toUTCStr(), parseLocalDateTime(), escapeICS()
│  │  ├─ data.js      # TEMP: DATA{} bis content.json aktiv ist
│  │  ├─ livebox.js   # withinLastDays(), formatCHDateLong(), renderLive()
│  │  ├─ agenda.js    # makeICSBlob(), formatCHDate(), renderAgenda()
│  │  ├─ filters.js   # buildFilters(), chip(), state
│  │  ├─ cards.js     # matchesFilters(), sortCards(), card(), render()
│  │  └─ app.js       # tick(), Event-Bindings, Boot
│  └─ data/
│     └─ content.json # Zielzustand für Inhalte (Agenda, Cards, Transparenz)
└─ README.md

````

---

## 2) Block-Marker (falls One-File-DIFF in `index.html`)
> Diese Marker machen DIFFs lesbar und minimieren Merge-Konflikte.

```html
<!-- @block:header --> … <!-- /@block:header -->

<!-- @block:hero -->
  <!-- @block:live-box --> … <!-- /@block:live-box -->
  <!-- @block:mini-agenda --> … <!-- /@block:mini-agenda -->
<!-- /@block:hero -->

<!-- @block:about --> … <!-- /@block:about -->
<!-- @block:filters --> … <!-- /@block:filters -->
<!-- @block:masonry --> … <!-- /@block:masonry -->
<!-- @block:footer --> … <!-- /@block:footer -->

<!-- @script:helpers --> … <!-- /@script:helpers -->
<!-- @script:data --> … <!-- /@script:data -->
<!-- @script:livebox --> … <!-- /@script:livebox -->
<!-- @script:agenda --> … <!-- /@script:agenda -->
<!-- @script:filters --> … <!-- /@script:filters -->
<!-- @script:cards --> … <!-- /@script:cards -->
<!-- @script:boot --> … <!-- /@script:boot -->
````

---

## 3) DOM-Outline (Soll)

```
main.wrap
└─ section.hero
   └─ .hero-grid
      ├─ .hero-copy
      │  ├─ h2 + p
      │  ├─ div.live-box (#liveList im Innern)
      │  └─ div.mini-agenda (#miniAgenda)
      └─ .tile.hero-portrait
```

---

## 4) Funktionsbaum (JS-Soll)

1. **Helpers:** `el`, `pad`, `toUTCStr`, `parseLocalDateTime`, `escapeICS`
2. **DATA/Loader:** vorerst `DATA{}`, später `fetch('src/data/content.json')`
3. **State/Chips:** `state`, `chip`, `buildFilters`
4. **Agenda:** `makeICSBlob`, `formatCHDate`, `renderAgenda` *(Entwicklungsphase: Slice auf 1)*
5. **Live-Box:** `withinLastDays`, **`formatCHDateLong` (neu)**, `renderLive` *(Metazeile mit Bereich/Ort/Datum)*
6. **Cards:** `matchesFilters`, `sortCards`, `card` *(Bereich-Pill statt Status)*, `render`
7. **Boot:** Events, `tick()`

---

## 5) Konkrete DIFF-Hunks (unified) – **exakt so übernehmen**

### 5.1 Live-Box-Metazeile: **Status → Bereich** und **langes Datum**

**Datei:** `index.html` (im `<script>` Block, Funktion `renderLive()`)

```diff
@@ function renderLive(){
-  host.appendChild(el("div",{class:"live-item"},[
-    el("strong",{}, c.title),
-    el("div",{class:"stamp"}, `Status: ${c.status} · ${c.region||''} · ${c.date}`),
-    el("div",{}, c.text),
-    el("div",{class:"proof"},"Nächster Schritt: " + (c.next||"–"))
-  ]));
+  host.appendChild(el("div",{class:"live-item"},[
+    el("strong",{}, c.title),
+    // Bereich = Thema; langes Datum im de-CH Format
+    el("div",{class:"stamp"}, `${c.theme} · ${c.region||''} · ${formatCHDateLong(c.date)}`),
+    el("div",{}, c.text),
+    el("div",{class:"proof"},"Nächster Schritt: " + (c.next||"–"))
+  ]));
 }
```

**Hilfsfunktion ergänzen** (oberhalb von `renderAgenda()` oder in Helper-Sektion):

```diff
+ // Langes Datum: „Sonntag, 21. September 2025“
+ function formatCHDateLong(dateStr){
+   const [Y,M,D]=(dateStr||"").split("-").map(Number);
+   const d=new Date(Y,(M||1)-1,D||1,0,0,0);
+   const fmt=new Intl.DateTimeFormat('de-CH',{weekday:'long',day:'2-digit',month:'long',year:'numeric'});
+   const s=fmt.format(d);
+   return s.charAt(0).toUpperCase()+s.slice(1);
+ }
```

### 5.2 Karten-Meta: **Status-Pill raus, Bereich-Pill rein**

**Datei:** `index.html` (Funktion `card(c)`)

```diff
@@ function card(c){
-  const meta=el("div",{class:"meta"},[
-    label(c.status,"status-"+statusClass(c.status).split("-")[1]),
-    label(c.theme,"them"),label(c.region||"","region"),label(c.date,"date"),
-  ]);
+  const meta=el("div",{class:"meta"},[
+    label(c.theme,"bereich"),           // Bereich = Thema
+    label(c.region||"","region"),
+    label(c.date,"date"),
+  ]);
```

**CSS für Bereich-Pill ergänzen** (im `<style>`):

```diff
 .label.date{background:#fff;color:var(--muted)}
+/* Bereich-Pill (ersetzt Status) */
+.label.bereich{background:#f1f7ea;border-color:var(--border);color:#333}
```

> **Hinweis:** `statusClass()` könnt ihr belassen (für Legacy/Styles), wird für die Meta-Pills nicht mehr aufgerufen.

### 5.3 Agenda: **Entwicklungsphase auf 1 Eintrag begrenzen**

**Datei:** `index.html` (Funktion `renderAgenda()`)

```diff
-  const items=(DATA.agenda||[]).slice(0,3);
+  const items=(DATA.agenda||[]).slice(0,1); // DEV: vorläufig 1 Eintrag; später via Maske/JSON erweiterbar
```

### 5.4 Chips-Zeile: Desktop **eine Zeile**, Mobile **Scroll + Snap**

**Datei:** `index.html` (im `<style>`)

```diff
 .chips{display:flex;flex-wrap:wrap;gap:.5rem}
@@
 @media(max-width:720px){
   ...
   .chips{overflow:auto;gap:.45rem;padding-bottom:.25rem;scroll-snap-type:x mandatory}
   .chips .chip{flex:0 0 auto;scroll-snap-align:start}
   .chips::-webkit-scrollbar{display:none}
   ...
 }
+/* Desktop: Chips nicht umbrechen */
+@media(min-width:721px){
+  #themes, #status{flex-wrap:nowrap;overflow-x:hidden;white-space:nowrap}
+  #themes .chip, #status .chip{flex:0 0 auto}
+}
```

---

## 6) Nicht tun (häufige Fehlerquellen)

* **Kein** Rename von Datenfeldern: In `DATA.cards[*]` bleiben `status`, `theme`, `region`, `date` bestehen. Wir ändern nur **Ausgabe**, nicht **Schema**.
* **Status-Styles nicht löschen**, bevor sicher ist, dass sie nirgends sonst referenziert werden.
* **Intl-API**: Auf `de-CH` achten; sonst stimmt das lange Datum nicht mit „Sonntag, 21. September 2025“.
* **Agenda-Slice**: In DEV-Phase bewusst `slice(0,1)` – bitte nicht auf 3 zurückdrehen.
* **Live-Box** nicht verschieben: bleibt **in** `.hero-copy` **oberhalb** der Mini-Agenda.

---

## 7) Prüfplan (manuell, 5 Minuten)

1. **Live-Box**

   * Mit Testdatum ≤30 Tage: zeigt **1 Eintrag** mit „`{theme} · {region} · Sonntag, 21. September 2025`“.
   * Ohne Eintrag im 30-Tage-Fenster: Fallback „Kein Update in diesem Monat“ + Datumsstempel.

2. **Agenda**

   * Zeigt **genau 1** Eintrag. `.ics`-Download funktioniert.

3. **Karten**

   * Meta zeigt **Bereich** (= Thema), **Region**, **Datum**.
   * **Keine** Status-Pill sichtbar.

4. **Chips-Zeile**

   * Desktop: **eine** Zeile, kein Umbruch.
   * Mobile: horizontales Scrollen mit Snap.

5. **A11y/Regressionen**

   * `aria-live="polite"` an `#liveList` vorhanden.
   * Fokusreihenfolge im Header/CTA unverändert.

---

## 8) Roadmap-Hooks (vorbereiten, aber noch nicht aktivieren)

* **Content-Lader** – Platzhalter für späteren Wechsel auf JSON:

  ```js
  // TODO(content): später ersetzen
  // const DATA = await (await fetch('src/data/content.json')).json();
  ```
* **Medienecho (optional)** – Textlink-Liste unter Transparenz (max. 3 Einträge), steuerbar via `content.json`.

---

## 9) Rollback-Plan (schnell)

* Revertet nur Commit 5.2 (Cards-Pill) und 5.1 (Live-Box-Metazeile), wenn Unklarheiten entstehen.
* Agenda-Slice kann unabhängig (Commit 5.3) zurückgestellt werden.
* CSS-Ergänzungen (Bereich-Pill, Chips-Desktop) sind additive und gefahrlos rücknehmbar.

---

## 10) Akzeptanzkriterien (final)

* Live-Box: Bereich · Ort · langes Datum, kein „Status: …“.
* Karten: Bereich-Pill statt Status-Pill.
* Agenda: 1 Eintrag (DEV).
* Chips-Zeile: Desktop eine Zeile; Mobile Scroll+Snap.
* Keine neuen A11y-/Layout-Regressions.

---

## 11) Anker für Code-Review

* **Sichtprüfung**: Above-the-Fold auf Mobile zuerst **Foto**, direkt danach **Live-Box**.
* **Textprüfung**: Typografisch Schweizer Deutsch (z. B. „Sprechstunde“, „massgeblich“, „Schliessen“ mit **ss**).
* **Datumsprüfung**: „Sonntag, 21. September 2025“ exakt so.

---

*Ende der Datei.*