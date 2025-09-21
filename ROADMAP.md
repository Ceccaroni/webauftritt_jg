**Rolle: Technischer Projektleiter (TPM/Lead Engineer)**

# Roadmap – Weiterentwicklung Webauftritt „Julia Grieder“

## Leitplanken

* **Tech-Stack:** reines HTML/CSS/JS (kein Framework), Inhalte perspektivisch aus `content.json`.
* **Ziele:** Glaubwürdigkeit (Belege), Bedienbarkeit (A11y, Mobile First), geringe Pflegekosten.
* **Nicht verhandelbar:** Live-Box bleibt als Benchmark; Motion respektiert `prefers-reduced-motion`.

---

## Phase 1 – Stabilisierung & sichtbare Quick Wins

### 1. Chips-Zeile stabilisieren (Layout, kein Logik-Change)

**Soll:** Desktop immer **eine** Zeile; Mobile horizontal scroll+snap.
**Tasks**

* Desktop: `white-space: nowrap`, sauberes Spacing, kein Umbruch; Überlauf verhindert.
* Mobile: Snap-Scroll beibehalten, Touch-Targets ≥ 40px.
* Visuelle Regressionen prüfen (Header/Parteilogo, Hero-Abstand).
  **DoD**
* Keine Zeilenbrüche/Überlappungen bei 1024–1920px.
* Mobile: flüssiges horizontales Scrollen, Fokus-/Tab-Reihenfolge korrekt.

### 2. Mobile „Top-Button“

**Soll:** Floating-Button ab 1 Bildschirmhöhe Scroll, nur Mobile (≤ 720px).
**Tasks**

* Sicht-/Unsichtbarkeit via IntersectionObserver oder Scroll-Threshold.
* A11y: `aria-label`, Fokusreihenfolge, Tastatur-Aktivierbarkeit.
* Motion: kein Parallax, respektiert `prefers-reduced-motion`.
  **DoD**
* Auf iOS/Android sichtbar, springt ohne Layout-Shift nach oben; Lighthouse A11y 100.

### 3. Transparenz-Kachel erweitern

**Soll:** Mindestens 2–3 Links zu Primärquellen.
**Tasks**

* Datenstruktur definieren (Titel, URL, optional Quelle/Datum).
* Rendering als `<ul><li><a…>`.
  **DoD**
* Links klickbar, semantisch korrekt, neue Registerkarte optional.

---

## Phase 2 – Inhalte entkoppeln & Benennung konsolidieren

### 4. Content-Auslagerung (`content.json`)

**Soll:** Agenda, Cards, Transparenz (und optional Medienecho) extern pflegbar.
**Tasks**

* Schema festlegen:

  ```json
  {
    "agenda":[{"date":"YYYY-MM-DD","time":"HH:MM","title":"…","place":"…","purpose":"…","ctaLabel":"…","ctaHref":"…"}],
    "cards":[{"id":"c1","title":"…","bereich":"Verkehr","region":"Brugg","date":"YYYY-MM-DD","text":"…","next":"…","media":"…","alt":"…"}],
    "transparency":[{"title":"…","href":"https://…"}],
    "medienecho":[{"title":"…","href":"https://…"}]
  }
  ```
* `fetch()` im Init, Fallback: leere Arrays, console.warn bei Ladefehler.
* CORS/Same-Origin sicherstellen (`/assets/content.json`).
  **DoD**
* Seite rendert ohne JS-Fehler, Daten kommen aus JSON; Offline-Fallback bricht UI nicht.

### 5. **Status → Bereich** (Daten & UI)

**Soll:** Einheitlich „Bereich“ statt „Status“.
**Tasks**

* Datenmodell umstellen: `cards[*].bereich`.
* Live-Box-Stamp: **„Bereich: {bereich} · {region} · {Datum lang}“**.
* Karten-Meta: Label zeigt `bereich`; Filter-Chips: thematische weiter wie bisher, Status-Chips bleiben, bis Politik entscheidet (nur UI-Text bleibt „Status“ oder wird später „Fortschritt“).
  **DoD**
* Keine Vorkommen von „Status“ in Live-Box/Karten-Meta; Build bricht, wenn Feld fehlt (dev-Warnung).

### 6. Datumsformat vereinheitlichen

**Soll:** Langform `de-CH` (Wochentag, Tag, Monat, Jahr) im sichtbaren Text.
**Tasks**

* Live-Box und Card-Meta aus ISO (`YYYY-MM-DD`) formatiert rendern.
* Agenda behält strukturiertes Schema, Anzeige weiterhin lokalisiert.
  **DoD**
* Beispiel erfüllt: „Bereich: Verkehr · Brugg · Sonntag, 21. September 2025“.

---

## Phase 3 – Agenda, Medienecho & Mikrotransition-Feinschliff

### 7. Agenda temporär auf **einen Eintrag** beschränken

**Soll:** Entwicklungsphase: genau 1 Termin in „Nächste Termine“.
**Tasks**

* Rendering `slice(0,1)`; Kommentar im Code für spätere Aufhebung.
* `.ics`-Export bleibt erhalten.
  **DoD**
* Genau ein Termin sichtbar; Live-Region (`aria-live=polite`) bleibt korrekt.

### 8. Optional: **Medienecho** (nice-to-have)

**Soll:** Max. 3 Links, Footer oder unter Transparenz.
**Tasks**

* Rendering wie Transparenz, Daten aus `content.json.medienecho`.
* Trunkierung langer Titel via CSS.
  **DoD**
* ≤ 3 Links, responsive, keine Layout-Sprünge.

### 9. Mikrotransitionen – QA & Performance

**Soll:** Spürbare, aber subtile Bewegungen; Motion-Sensitivity respektiert.
**Tasks**

* FLIP-Reorder bei Filter-Priorisierung validieren (iOS Safari, Android Chrome).
* `prefers-reduced-motion` Pfad: alle Transitions deaktiviert.
* Messung: keine spürbare Reflow-Kaskade bei 20+ Karten.
  **DoD**
* 60fps-Gefühl bei modernen Geräten; keine A11y-Flags.

---

## Phase 4 – Qualitätssicherung & Regressionen

### 10. A11y-/SEO-Audit

**Tasks**

* Axe/Lighthouse: Mängel < minor, Kontraste, Fokus-Outline, Landmarks.
* `aria-live` (Live-Box, Agenda) korrekt dezent.
* H1-Struktur, Meta-Description, Bild-`alt`.
  **DoD**
* Lighthouse A11y ≥ 95, SEO ≥ 90.

### 11. Cross-Browser-Test

**Matrix:** iOS Safari, Android Chrome, macOS Safari/Chrome/Firefox, Edge (Win).
**DoD**

* Keine Layout-Shifts; Header/Parteilogo korrekt; Hero-Reihenfolge wie gewünscht.

### 12. Technische Schulden/Housekeeping

**Tasks**

* Backtick-Sanitizer im Init belassen (Schutz vor Copy-Paste), aber als util kapseln.
* Fehler-Handling bei `fetch()` (Timeout, 404).
* Code-Kommentar-Header: Pflegehinweise für Kundin (wo Inhalte zu ändern sind).
  **DoD**
* Saubere Konsolenlogs (keine Errors), klare Dev-Kommentare.

---

## Abhängigkeiten

* **5 ← 4:** „Bereich“ hängt von `content.json`-Umstellung ab.
* **7 ← 4:** Agenda-Limit nutzt Daten aus JSON.
* **8 ← 4:** Medienecho speist sich aus JSON.
* **9** unabhängig (nur QA).

---

## Akzeptanzkriterien (gesamt)

* Desktop: Chips-Zeile einzeilig; Mobile: Scroll+Snap; keine Überlappung.
* Live-Box bleibt funktional, zeigt **eine** Leistung (≤ 30 Tage) mit „Bereich“ + langem Datum, sonst Fallback-Text mit Datumsstempel.
* Transparenz: ≥ 2 Primärquellen-Links sichtbar.
* `content.json` erfolgreich geladen; UI robust bei Fehlern.
* Agenda: aktuell 1 Eintrag; `.ics`-Download funktionsfähig.
* Optionales Medienecho (falls aktiviert): ≤ 3 Links.
* Motion: `prefers-reduced-motion` respektiert; Animationen subtil.
* A11y/SEO Audits im grünen Bereich; Cross-Browser ok.

---

## Risiken & Gegenmassnahmen

* **CORS/Hosting:** JSON vom gleichen Origin ausliefern → `/assets/content.json`.
* **Datumsqualität:** Inkonsistente Formate → strikt ISO in JSON, Anzeige lokalisiert im Code.
* **Pflegefehler:** Fehlende Felder → defensive Defaults + sichtbare Dev-Warnungen.

---

## Lieferung & Reihenfolge (empfohlen)

1. **Phase 1** (Chips, Top-Button, Transparenz)
2. **Phase 2** (`content.json`, „Bereich“, Datum)
3. **Phase 3** (Agenda-Limit, Medienecho, Micro-QA)
4. **Phase 4** (Audits, Cross-Browser, Cleanup)

> Hinweis: „Top-Button“ ist bereits als Wunsch der Kundin markiert und hier fest eingeplant (Phase 1).
