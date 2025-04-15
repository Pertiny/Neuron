# 🧠 Neuron – Minimalistischer iOS-Client für ChatGPT

Neuron ist ein schlanker, datenschutzfreundlicher iOS-Client, mit dem du die OpenAI ChatGPT API über deinen eigenen API-Key nutzen kannst – ohne fremde Server, Werbung oder Schnickschnack.

![Neuron Screenshot Dark](./Assets/screenshot_dark.png)

---

## 🚀 Features

- 🔑 Eigener OpenAI API-Key (lokal gespeichert, kein Tracking)
- 💬 Minimalistisches Chat-Interface mit Monospace-Typografie
- 🎛️ Anpassbare KI-Parameter (Temperatur, Token-Limit, Modellwahl, System-Prompt)
- 🗂️ Chat-Verläufe mit Ordnern, Archivierung und Löschfunktion
- 🌙 Einheitliches dunkles Design mit eigenem "<"-Back-Button
- 🔒 Keine Cloud-Abhängigkeit, vollständige Offline-Persistenz

---

## 📱 Screenshots

*(Hier kannst du Screenshots oder GIFs einfügen)*

---

## ⚙️ Tech-Stack

| Komponente       | Beschreibung                     |
|------------------|----------------------------------|
| Sprache          | Swift                            |
| UI-Framework     | SwiftUI (iOS 15+)                |
| Architektur      | MVVM-light                       |
| Speicherung      | UserDefaults mit `Codable`       |
| API-Anbindung    | OpenAI ChatGPT API               |

---

## 🛠️ Projektstruktur (Auszug)

```
Neuron/
├── Models/
│   ├── ChatSession.swift
│   └── ChatMessage.swift
├── Views/
│   ├── ChatView.swift
│   ├── ContentView.swift
│   ├── ChatSettingsView.swift
│   └── HistoryView.swift
├── Storage/
│   └── ChatStorage.swift
├── Network/
│   └── APIManager.swift
└── NeuronApp.swift
```

---

## 🧪 Installation

1. Projekt klonen:
   ```bash
   git clone https://github.com/Pertiny/Neuron.git
   ```
2. In Xcode öffnen: `Neuron.xcodeproj`
3. OpenAI API-Key im Startscreen eingeben (erforderlich)

---

## 🧩 Roadmap / TODOs

- [ ] Einheitliches Back-Button-Verhalten über alle Views
- [ ] Erweiterte Chat-Organisation (Ordnerstruktur, Tagging)
- [ ] Optional: iCloud-Sync von Chat-Verläufen
- [ ] Optional: Export-Funktion für Konversationen

---

## 📄 Lizenz

MIT License – frei verwendbar, keine Garantie.  
Bitte verwende deine eigene OpenAI API, um Datenschutz & Kostenkontrolle zu gewährleisten.

---

## 🙌 Mitmachen?

Pull Requests & Ideen willkommen!  
Kontakt: [pertiny@protonmail.com] *(anpassbar)*
