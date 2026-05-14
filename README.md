<<<<<<< HEAD
# gwana
=======
# GWANA - Réseau de Valorisation des Femmes Pionnières

Plateforme web professionnelle pour le réseau GWANA, dédiée à la valorisation de femmes pionnières et expertes qui exercent des métiers à connotation masculine au Niger et au mentorat.

## 🎯 Objectifs

- Mettre en place un réseau de femmes expertes et mentors
- Faciliter les demandes de mentorat
- Créer un annuaire de membres avec recherche avancée
- Publier des actualités et articles
- Fournir un dashboard d'administration complet

## 🚀 Technologies

- **Framework**: Rails 8.0.4
- **Base de données**: PostgreSQL
- **Authentification**: Devise avec confirmable
- **Autorisation**: Pundit
- **Background Jobs**: Sidekiq + Redis
- **Recherche**: pg_search (PostgreSQL full-text search)
- **Storage**: ActiveStorage (local + S3/DO Spaces)
- **Frontend**: Tailwind CSS + Stimulus
- **Tests**: RSpec + FactoryBot + Shoulda Matchers
- **Linting**: RuboCop

## 📋 Prérequis

- Ruby 3.3+ (voir `.ruby-version`)
- PostgreSQL 15+
- Redis 7+
- Node.js 18+ (pour les assets)
- Bundler

## 🔧 Installation

### 1. Cloner le repository

```bash
git clone <repository-url>
cd gwana
```

### 2. Installer les dépendances

```bash
bundle install
npm install
```

### 3. Configurer la base de données

```bash
# Créer les bases de données
rails db:create

# Exécuter les migrations
rails db:migrate

# (Optionnel) Charger les données de seed
rails db:seed
```

### 4. Configurer les credentials

```bash
# Éditer les credentials Rails
EDITOR="code --wait" rails credentials:edit

# Ajouter les clés nécessaires (voir section Configuration)
```

### 5. Démarrer les services

```bash
# Terminal 1: Rails server
bin/dev

# Terminal 2: Sidekiq (si nécessaire)
bundle exec sidekiq

# Terminal 3: Redis (si non démarré automatiquement)
redis-server
```

## ⚙️ Configuration

### Variables d'environnement

Créer un fichier `.env` à la racine du projet (ou utiliser les credentials Rails) :

```bash
# Database
DATABASE_URL=postgres://localhost:5432/gwana_development
PGUSER=postgres
PGPASSWORD=postgres

# Redis
REDIS_URL=redis://localhost:6379/0

# ActiveStorage (Production)
# Pour DigitalOcean Spaces:
# ACTIVE_STORAGE_SERVICE=digitalocean
# Pour AWS S3:
# ACTIVE_STORAGE_SERVICE=amazon
```

Ce projet utilise `dotenv-rails` en développement et test pour charger automatiquement
les variables définies dans `.env`.

### Credentials Rails

```bash
EDITOR="code --wait" rails credentials:edit
```

Ajouter les clés suivantes :

```yaml
# DigitalOcean Spaces (optionnel)
digitalocean:
  spaces_access_key_id: your_key
  spaces_secret_access_key: your_secret
  spaces_region: nyc3
  spaces_bucket: your-bucket-name

# AWS S3 (optionnel)
aws:
  access_key_id: your_key
  secret_access_key: your_secret
  region: us-east-1

# SMTP (optionnel, pour les emails)
smtp:
  user_name: your_username
  password: your_password
  address: smtp.example.com
  port: 587
```

## 🧪 Tests

### Lancer les tests

```bash
# Tous les tests
bundle exec rspec

# Un fichier spécifique
bundle exec rspec spec/models/user_spec.rb

# Avec coverage
COVERAGE=true bundle exec rspec
```

### Linting

```bash
# RuboCop
bundle exec rubocop

# Auto-correction
bundle exec rubocop -a

# Brakeman (sécurité)
bundle exec brakeman
```

## 📁 Structure du projet

```
app/
  controllers/          # Controllers (logique de contrôle uniquement)
  models/               # Modèles (logique métier, validations, associations)
  policies/             # Pundit policies (autorisations)
  services/             # Services (logique métier complexe)
  helpers/              # Helpers (formatage pour les vues)
  views/                # Vues ERB
  javascript/
    controllers/        # Stimulus controllers
  mailers/              # Mailers pour les notifications
```

## 🎨 Design & Palette de couleurs

- **Violet principal**: `#6A0DAD`
- **Violet profond**: `#5B21B6`
- **Noir charbon**: `#0B0B0B`
- **Noir foncé**: `#111111`
- **Or chaud**: `#D4AF37`
- **Or accent**: `#B8860B`
- **Accent clair**: `#EDE7F6`
- **Background**: `#0F1724`

### Typographie

- **UI**: Inter (Google Fonts)
- **Titres**: Merriweather (Google Fonts)

## 🔐 Rôles et permissions

- **member** (0): Membre standard
- **mentor** (1): Mentor disponible pour le mentorat
- **admin_reseau** (2): Administrateur réseau
- **admin** (3): Administrateur système

## 📝 Commandes utiles

### Développement

```bash
# Démarrer le serveur de développement
bin/dev

# Console Rails
rails console

# Générer un modèle
rails generate model ModelName field:type

# Créer une migration
rails generate migration MigrationName

# Exécuter les migrations
rails db:migrate

# Rollback
rails db:rollback
```

### Production

```bash
# Précompiler les assets
rails assets:precompile

# Vérifier les migrations en attente
rails db:migrate:status

# Exécuter les migrations en production
RAILS_ENV=production rails db:migrate
```

## 🚢 Déploiement

### Heroku

```bash
# Installer Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Créer l'application
heroku create gwana-app

# Ajouter les addons
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini

# Configurer les variables d'environnement
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Déployer
git push heroku main

# Exécuter les migrations
heroku run rails db:migrate

# Créer un utilisateur admin
heroku run rails console
# User.create!(email: 'admin@example.com', password: 'password', role: :admin, confirmed_at: Time.current)
```

### DigitalOcean

Voir la configuration Kamal dans `config/deploy.yml` et `Dockerfile`.

```bash
# Déployer avec Kamal
kamal setup
kamal deploy
```

## 📚 Documentation API

L'API JSON est versionnée et accessible via `/api/v1/`. (À implémenter)

## 🤝 Contribution

1. Créer une branche feature (`git checkout -b feature/amazing-feature`)
2. Commiter les changements (`git commit -m 'feat: Add amazing feature'`)
3. Pousser vers la branche (`git push origin feature/amazing-feature`)
4. Ouvrir une Pull Request

### Convention de commits

Utiliser [Conventional Commits](https://www.conventionalcommits.org/) :

- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage, point-virgules manquants, etc.
- `refactor:` Refactoring
- `test:` Ajout/modification de tests
- `chore:` Maintenance

## 📄 Licence

[À définir]

## 👥 Équipe

GWANA Network

## 🔗 Liens

- [Documentation Rails](https://guides.rubyonrails.org/)
- [Documentation Devise](https://github.com/heartcombo/devise)
- [Documentation Pundit](https://github.com/varvet/pundit)
- [Documentation Sidekiq](https://sidekiq.org/)

## 🐛 Problèmes connus

- [ ] Implémenter les mailers pour les notifications de mentorat
- [ ] Ajouter les tests d'intégration complets
- [ ] Implémenter l'API JSON versionnée
- [ ] Ajouter les exports CSV/PDF pour le dashboard admin

## 📅 Roadmap

### Sprint 0 (Terminé)
- ✅ UI Layout
- ✅ Configuration de base

### Sprint 1 (En cours)
- ✅ Auth + rôles
- ✅ Modèles Member
- ✅ Admin de base
- ✅ Header/footer

### Sprint 2 (À venir)
- [ ] Annuaire + recherches
- [ ] Pages de profil
- [ ] Upload ActiveStorage

### Sprint 3 (À venir)
- [ ] Flow de mentorat complet
- [ ] Notifications
- [ ] Dashboard mentorat

### Sprint 4 (À venir)
- [ ] Opportunités
- [ ] Actualités complètes
- [ ] Dashboard admin + reporting

### Sprint 5 (À venir)
- [ ] Tests complets
- [ ] Polish UI
- [ ] Accessibilité WCAG AA
- [ ] Déploiement staging
>>>>>>> 916a3be (project base architecture with first page)
