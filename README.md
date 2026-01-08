# System Poziomów (Gun XP Mod) dla CS 1.6

**Autor:** Amator / SkyDev  
**Wersja:** 1.0  
**Platforma:** Counter-Strike 1.6, AMX Mod X  

---

## Opis

Plugin **System Poziomów** dodaje mechanikę zdobywania doświadczenia (EXP) i awansowania poziomów w grze. Zawiera system odblokowywania broni, menu wyboru broni oraz efekty wizualne i dźwiękowe przy awansie.

---

## Funkcje

| Funkcja | Opis |
|---------|------|
| System EXP i poziomów | - Zabójstwa dają 10 XP, headshoty 15 XP <br> - EXP zapisywane w SQL i przywracane po reconnectach <br> - Awans gracza wywołuje efekty wizualne i dźwiękowe |
| Odblokowywanie broni | - Broń odblokowywana na określonych poziomach <br> - Poziom **Gold** (24) wprowadza złote modele broni <br> - Możliwość wyboru pistoletu i broni głównej w menu <br> - Pamiętanie ostatniego zestawu broni |
| Menu i komendy | - `/bronie` – menu wyboru broni <br> - `/levelup` – menu administracyjne do zmiany poziomów graczy <br> - `/topxp` – wyświetlenie top 10 graczy wg poziomu i EXP |
| Obsługa SQL | - Automatyczne tworzenie tabeli `gunxpmod_players` <br> - Zapisywanie i ładowanie danych graczy (poziom, EXP, ostatnia broń) |
| HUD | - Wyświetlanie poziomu i EXP w HUD gracza <br> - Aktualizacja po zdobyciu EXP lub awansie |
| Kompatybilność | - BaseBuilder: menu dostępne tylko w fazach budowy/prep dla builderów <br> - Zombie: rozpoznaje, czy gracz jest zombie, nie daje broni ani EXP |

---

## Wymagania

- **AMX Mod X**  
- Moduły: `amxmisc`, `fakemeta`, `hamsandwich`, `cstrike`, `fun`, `sqlx`, `engine`, `basebuilder`  
- Serwer CS 1.6 z włączonym SQL (MySQL lub SQLite)

---

## Instalacja

1. Skopiuj plik `.sma` do katalogu `scripting` w AMX Mod X.  
2. Skompiluj plugin przy użyciu `compile.exe`.  
3. Skopiuj `.amxx` do folderu `plugins`.  
4. Dodaj nazwę pluginu do `plugins.ini`.  
5. Upewnij się, że serwer ma włączone SQL (`modules/sqlx.cfg`) i dostęp do bazy danych.

---

## Workflow działania

1. Gracz zabija przeciwnika → zdobywa EXP.  
2. Po osiągnięciu wymaganego EXP → awans gracza + efekty dźwiękowe i wizualne.  
3. Odblokowują się nowe pistolety lub broń główna.  
4. Gracz używa `/bronie` do wyboru aktualnego zestawu broni lub ostatniego zestawu.  
5. Administracja może ręcznie zmieniać poziomy graczy poprzez `/levelup`.  

---

## Komendy

| Komenda | Opis |
|---------|------|
| `/bronie` | Wywołuje menu wyboru broni dla gracza |
| `/levelup` | Menu administracyjne do zmiany poziomów innych graczy |
| `/topxp` | Wyświetla ranking top 10 graczy według poziomu i EXP |
