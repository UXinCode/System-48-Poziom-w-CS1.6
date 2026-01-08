# System-48-Poziom-w-CS1.6
Plugin System Poziomów dodaje do gry mechanikę zdobywania doświadczenia (EXP) i awansowania poziomów dla graczy, wraz z odblokowywaniem broni oraz efektami wizualnymi i dźwiękowymi przy awansie. Jest kompatybilny z modułami BaseBuilder oraz obsługuje integrację ze standardowym trybem Zombie (BB Zombies). | Do dalszej aktualizacji dla graczy |
Główne funkcje pluginu:

System EXP i poziomów:

Gracze zdobywają EXP za zabójstwa (10 XP) i headshoty (15 XP).

Doświadczenie jest zapisywane w SQL i przywracane po reconnectach.

Po osiągnięciu odpowiedniego poziomu następuje awans gracza wraz z efektami wizualnymi (sprite) i dźwiękowymi (levelup.wav).

Odblokowywanie broni:

Broń odblokowuje się na określonych poziomach.

Poziom Gold (lvl 24) wprowadza modele złotej broni.

Możliwość wyboru pistoletu i broni głównej w menu.

Pamiętanie ostatnio wybranego zestawu broni.

Menu i komendy:

/bronie – wywołanie menu wyboru broni.

/levelup – menu administracyjne do ręcznego nadawania poziomów graczom.

/topxp – wyświetlenie top 10 graczy wg poziomu i EXP.

System menu jest kompatybilny z fazami budowania/prep BaseBuilder.

Obsługa SQL:

Automatyczne tworzenie tabeli gunxpmod_players przy pierwszym uruchomieniu.

Zapisywanie i ładowanie danych graczy (poziom, EXP, ostatnia broń).

Integracja z HUD:

Wyświetlanie aktualnego poziomu i EXP nad HUD gracza.

Dynamiczne aktualizacje po zdobyciu EXP lub awansie.

Kompatybilność:

BaseBuilder (bb_is_build_phase, bb_is_prep_phase) – menu dostępne tylko w fazach budowy/prep dla builderów.

Obsługa zombie – plugin rozpoznaje, czy gracz jest zombie i nie daje broni ani EXP.

Wymagania

AMX Mod X

Moduły: amxmisc, fakemeta, hamsandwich, cstrike, fun, sqlx, engine, basebuilder

Serwer CS 1.6 z włączonym SQL (MySQL lub SQLite)

Instalacja

Skopiuj plik .sma do katalogu scripting w AMX Mod X.

Skompiluj plugin przy użyciu compile.exe w AMX Mod X.

Skopiuj .amxx do folderu plugins.

Dodaj nazwę pluginu do plugins.ini.

Upewnij się, że serwer ma włączone SQL (modules/sqlx.cfg) i dostęp do bazy danych.

Przykładowy workflow

Gracz zabija przeciwnika → zdobywa EXP.

Po osiągnięciu wymaganego EXP następuje awans → dźwięk + efekt sprite.

Odblokowują się nowe pistolety lub broń główna.

Gracz może w menu /bronie wybrać aktualny zestaw broni lub użyć ostatniego.

Administracja może ręcznie zmieniać poziomy graczy poprzez /levelup.
