# Mon Budget — Synchronisation cloud entre appareils
Base de données : https://supabase.com/dashboard/project/nfpdttxdaumatzjtfsfx
Application web installable (PWA) avec **synchronisation cloud temps réel** via [Supabase](https://supabase.com), une plateforme open-source ([github.com/supabase/supabase](https://github.com/supabase/supabase)).

## ✨ Architecture

- **Frontend** : HTML/CSS/JS pur, fonctionne sur n'importe quel téléphone, gratuit
- **Backend cloud** : Supabase (PostgreSQL + Auth + Realtime) — open source, gratuit jusqu'à 500 Mo
- **Cache local** : IndexedDB sur ton téléphone — l'app fonctionne hors-ligne
- **Sync** : push automatique à chaque changement + pull au démarrage + temps réel via WebSocket

Tes données t'appartiennent : elles sont dans **ton** compte Supabase, sécurisées par Row Level Security (RLS) — chaque utilisateur ne voit que ses propres données.

## 📦 Fichiers inclus

- `index.html` — application complète
- `manifest.json` — config PWA
- `sw.js` — service worker (mode hors-ligne)
- `setup.sql` — schéma SQL à exécuter dans Supabase une fois
- `icon-192.png` / `icon-512.png` — icônes
- `README.md` — ce guide

## 🚀 Installation — étape par étape

### Étape 1 : Créer ton projet Supabase (5 min, gratuit)

1. Va sur [supabase.com](https://supabase.com) et clique sur **Start your project**
2. Inscris-toi (avec GitHub, Google, ou email)
3. Clique sur **New project**
4. Choisis :
   - **Name** : `mon-budget` (ou ce que tu veux)
   - **Database password** : génère-en un solide, garde-le quelque part
   - **Region** : la plus proche de toi (ex. `West EU (London)` pour le Maroc)
5. Clique sur **Create new project** et attends ~2 minutes que la base soit prête

### Étape 2 : Créer la table de la base de données

1. Dans ton projet Supabase, dans le menu de gauche, clique sur **SQL Editor**
2. Clique sur **+ New query**
3. Ouvre le fichier `setup.sql` (fourni dans le ZIP), copie tout son contenu
4. Colle-le dans l'éditeur SQL et clique sur **Run** (ou Ctrl+Entrée)
5. Tu devrais voir « Success. No rows returned » — la table et les règles de sécurité sont créées

### Étape 3 : Récupérer tes clés API

1. Dans ton projet Supabase, va dans **Settings** (icône engrenage en bas à gauche) → **API**
2. Note ces deux valeurs :
   - **Project URL** : `https://xxxxxx.supabase.co`
   - **anon / public key** : longue chaîne commençant par `eyJ...` (cette clé est faite pour être publique)

### Étape 4 : Désactiver la confirmation par email (optionnel mais conseillé)

Pour pouvoir te connecter immédiatement après inscription sans avoir à confirmer ton email :

1. Va dans **Authentication** → **Providers** → **Email**
2. Décoche **Confirm email**
3. Clique sur **Save**

> 💡 Tu peux la réactiver plus tard si tu veux plus de sécurité.

### Étape 5 : Déployer l'app sur HTTPS

L'app a besoin d'un hébergement en HTTPS pour être installable comme PWA. Le plus simple :

**Option A — Netlify Drop (30 secondes, gratuit, sans compte)**
1. Va sur [app.netlify.com/drop](https://app.netlify.com/drop)
2. Glisse-dépose le **dossier `budget-app-cloud`** dessus
3. Tu obtiens immédiatement une URL HTTPS

**Option B — GitHub Pages (gratuit, plus permanent)**
1. Crée un dépôt public sur [github.com](https://github.com)
2. Upload tous les fichiers
3. Active **Pages** dans Settings → Pages → Source: `main` / root
4. URL : `https://TON_NOM.github.io/TON_REPO/`

### Étape 6 : Installer et configurer sur ton Samsung

1. Ouvre l'URL dans **Chrome** sur ton Samsung
2. Tape **Menu (⋮) → Ajouter à l'écran d'accueil**
3. Lance l'app depuis l'icône
4. Tape sur **Activer** dans la bannière (ou Menu ⋮ → Activer la synchronisation cloud)
5. Colle ton **URL** et ta **clé anon** Supabase
6. Clique **Enregistrer**
7. Onglet **Inscription** : crée ton compte avec email + mot de passe
8. C'est tout ! Tes opérations seront synchronisées automatiquement ✨

### Étape 7 : Synchroniser un autre appareil

1. Ouvre la même URL sur l'autre appareil (téléphone, tablette, PC, etc.)
2. Installe-la comme PWA si tu veux
3. Dans le menu, active le cloud avec **les mêmes URL + clé Supabase**
4. **Connecte-toi** avec le même email/mot de passe
5. Toutes tes données apparaissent automatiquement 🎉
6. Toute modification d'un appareil apparaît en temps réel sur l'autre

## 🔐 Sécurité

- La clé "anon" est conçue pour être exposée côté client — elle ne donne accès qu'aux opérations autorisées par les règles **Row Level Security** définies dans `setup.sql`
- Chaque utilisateur ne peut voir/modifier QUE ses propres transactions (filtre `auth.uid() = user_id`)
- Les mots de passe sont hashés par Supabase avec bcrypt
- Les sessions sont stockées localement avec rotation automatique des tokens

## 🌐 Mode hors-ligne

L'app fonctionne sans Internet :
- **Lecture** : depuis IndexedDB (cache local)
- **Écriture** : dans IndexedDB avec `synced: false`
- **Au retour en ligne** : les changements en attente sont automatiquement push vers le cloud

L'indicateur de statut en haut affiche :
- 🟢 **Synchronisé** — tout est à jour
- 🟡 **Synchronisation…** — en cours
- ⚪ **Hors-ligne** — pas de réseau, les modifs seront synchronisées au retour
- 🔴 **Erreur de sync** — vérifier les logs (console)
- ⚪ **Mode local** — pas de cloud configuré

## 📡 Synchronisation temps réel

L'app s'abonne aux changements PostgreSQL via WebSocket. Quand tu ajoutes une dépense sur ton téléphone, elle apparaît instantanément sur ta tablette/PC sans rafraîchissement.

## 🆓 Limites gratuites Supabase

- 500 Mo de base de données (~100 000+ transactions)
- 50 000 utilisateurs auth
- Pause après 7 jours d'inactivité (réveil instantané au prochain accès)
- 2 Go bande passante / mois
- 2 projets gratuits simultanés

Largement suffisant pour un usage personnel et familial.

## 🛠️ Auto-hébergement (avancé)

Si tu veux héberger Supabase toi-même (100 % open-source, contrôle total) :

```bash
git clone --depth 1 https://github.com/supabase/supabase
cd supabase/docker
cp .env.example .env
docker compose up -d
```

Puis dans l'app, mets l'URL de ton instance auto-hébergée à la place de `*.supabase.co`.

Doc complète : [supabase.com/docs/guides/self-hosting](https://supabase.com/docs/guides/self-hosting)

## 🔄 Alternatives open-source

Si tu veux explorer d'autres options open-source équivalentes :

- **[PocketBase](https://pocketbase.io)** — un seul binaire Go + SQLite, ultra-simple à auto-héberger
- **[Appwrite](https://appwrite.io)** — alternative complète, cloud gratuit + auto-hébergeable
- **[Nhost](https://nhost.io)** — basé sur Hasura/PostgreSQL, GraphQL natif
- **[Directus](https://directus.io)** — plus orienté CMS mais très flexible

Le code de cette app est facilement adaptable à n'importe lequel — il suffit de remplacer la couche `initSupabaseClient` et `syncEngine` dans `index.html`.

## ❓ FAQ

**Et si je perds mon mot de passe ?**
Va sur ton dashboard Supabase → Authentication → Users → trouve ton compte → "Send password recovery". Ou bien implémente un bouton "mot de passe oublié" dans l'app (non inclus actuellement).

**Comment supprimer mon compte ?**
Dashboard Supabase → Authentication → Users → supprime ton utilisateur. Toutes tes données seront supprimées en cascade grâce à la contrainte `on delete cascade`.

**Mes données partent-elles chez Anthropic / autres ?**
Non. Les données vont uniquement de ton appareil vers TON projet Supabase. Anthropic n'a aucun accès. Le code source est entièrement à toi.

**Puis-je partager des données avec quelqu'un ?**
Pas dans cette version (chaque utilisateur a ses propres données). Si tu veux partager un budget familial, il faudrait modifier les règles RLS — demande, je peux ajouter cette fonctionnalité.
