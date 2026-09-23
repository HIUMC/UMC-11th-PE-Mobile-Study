# MovieLog

MovieLog is a small Flutter app for browsing movie mock data, opening movie details, saving favorites, and recording a personal rating.

## Run

```bash
flutter pub get
flutter run
```

The app opens on the home tab. The bottom navigation switches between Home, Movies, and My Page. Movie cards open `/movies/:movieId`, and genre/search conditions are represented in the Movies route query parameters.

## Project structure

- `lib/router/` — GoRouter routes and tab navigation
- `lib/data/` — shared mock movies and in-memory favorites/ratings
- `lib/models/` — movie model
- `lib/screens/` — home, movie list, detail, profile, and registration screens
- `lib/widgets/` — reusable movie cards and rating controls
- `lib/theme/` — shared colors and Material theme
- `assets/` — app logo, icons, posters, profile image, and Manrope font

Movie ratings and favorites are kept in memory for the practice app. No server or persistence layer is connected.
