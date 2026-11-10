# Arambh 2.0 mobile app

This folder contains the mobile-first, installable PWA version of the supplied Arambh 2.0 robotics marketplace. It preserves the existing product catalog, categories, search, sorting, cart, Instagram order and product inquiry flows, community seller listings, Supabase inventory/settings, real-time product updates, and owner dashboard.

## Deploy to GitHub Pages

Upload the **contents of this folder** to the same published directory in the `Arambh2.0` repository. Keep `index.html`, `admin.html`, `theme.css`, `config.js`, `schema.sql`, `manifest.webmanifest`, `service-worker.js`, and the `icons` folder together. Do not place the files in a nested `Arambh2-mobile` directory unless that directory is intentionally configured as the Pages site root.

In the repository, open **Settings → Pages** and select **Deploy from a branch**. Choose the branch containing these files and its published folder (usually `/(root)`), then save. If the repository already publishes Pages from a custom folder or GitHub Actions workflow, keep that source and put the files in its published directory so existing deployment behavior remains intact.

The app uses paths relative to its own published directory. That supports a project site at `https://<owner>.github.io/Arambh2.0/` without changing URLs to the domain root. The original provided site URL spells the repository path `Arambh2.O` with an uppercase letter O; relative paths also work with that spelling if that is the repository's exact slug.

## Supabase configuration

The supplied `config.js` contains the project's existing Supabase URL and browser publishable key. It is intended for browser use with database Row Level Security. Keep this key aligned with the existing project and never replace it with a `service_role` key. `admin.html` and `schema.sql` are included from the supplied project to preserve its owner dashboard and existing database setup.

## Install on a phone

- **Android:** open the deployed site in Chrome and choose **Install app** or **Add to Home screen** from the browser menu.
- **iPhone/iPad:** open the deployed site in Safari, tap **Share**, then **Add to Home Screen**.

The service worker caches the app shell for faster repeat loading and a basic offline page shell. Product inventory, owner actions, and Instagram ordering need an internet connection.

## Mobile adaptations

The shop header is condensed for narrow screens, category chips scroll horizontally, product cards and dialogs fit phone widths, controls have larger tap targets, and dialogs respect device safe areas. Desktop layout remains fluid.

The service worker limits caching and cache cleanup to this app's path and cache namespace, which is important because GitHub Pages project sites share a domain.

