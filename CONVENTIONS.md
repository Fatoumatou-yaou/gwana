# Conventions de code - GWANA

## Architecture & Séparation des responsabilités

### Controllers
- **Rôle**: Logique de contrôle uniquement
- **Contient**: Chargement des données, appels aux services, redirections, rendu de vue
- **Interdit**: Logique métier, calculs complexes, règles applicatives

### Models
- **Rôle**: Logique métier propre à l'objet
- **Contient**: Validations, associations, scopes, méthodes métier simples
- **Interdit**: Logique transactionnelle complexe, intégrations externes

### Services
- **Rôle**: Logique métier avancée et calculs complexes
- **Contient**: Règles fiscales, intégrations externes (e-Trésor, iPay), calculs complexes
- **Localisation**: `app/services/`
- **Convention**: `ServiceName.call(params)` ou `ServiceName.new(params).call`

### Helpers
- **Rôle**: Formatage et affichage pour les vues
- **Contient**: Formatage de montants, couleurs, labels
- **Interdit**: Logique métier, règles applicatives

### Decorators / Presenters
- **Rôle**: Enrichissement des modèles pour la présentation
- **Contient**: Libellés, formats, calculs simples d'affichage
- **Interdit**: Logique transactionnelle, logique métier importante

### Views
- **Rôle**: Déclaratif uniquement
- **Contient**: HTML + helpers simples
- **Interdit**: Logique de calcul, règles métier, traitement Ruby lourd

### Policies (Pundit)
- **Rôle**: Logique d'autorisation
- **Contient**: Qui peut faire quoi
- **Interdit**: Logique métier

## JavaScript

### Interdiction totale de JavaScript inline
- ❌ Pas de `onclick=`, `<script>`, fonctions JS dans les templates ERB
- ✅ Toute logique front doit être dans des Stimulus controllers
- ✅ Localisation: `app/javascript/controllers/`

## Naming Conventions

### Models
- Nom au singulier: `User`, `Member`, `Article`
- Associations: `has_many :articles`, `belongs_to :user`

### Controllers
- Nom au pluriel: `MembersController`, `ArticlesController`
- Actions RESTful: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`

### Services
- Nom au singulier avec suffixe `Service`: `MentorshipService`, `NotificationService`
- Méthode principale: `call` ou `perform`

### Policies
- Nom au singulier avec suffixe `Policy`: `MemberPolicy`, `ArticlePolicy`

## Tests

### Structure
- `spec/models/` - Tests de modèles
- `spec/controllers/` - Tests de controllers
- `spec/requests/` - Tests d'intégration
- `spec/services/` - Tests de services
- `spec/policies/` - Tests de policies

### Factories
- Localisation: `spec/factories/`
- Nom au pluriel: `users.rb`, `members.rb`
- Utiliser Faker pour les données de test

## Git & Commits

### Branches
- `main` - Production
- `develop` - Développement
- `feature/feature-name` - Nouvelles fonctionnalités
- `fix/bug-name` - Corrections de bugs
- `refactor/refactor-name` - Refactoring

### Commits
Utiliser [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add mentorship request feature
fix: Fix user authentication bug
docs: Update README with deployment instructions
style: Fix RuboCop offenses
refactor: Extract service from controller
test: Add tests for Member model
chore: Update dependencies
```

## Code Style

### Ruby
- Suivre les conventions RuboCop Rails Omakase
- Longueur de ligne: 120 caractères max
- Indentation: 2 espaces

### ERB
- Utiliser `<% %>` pour la logique
- Utiliser `<%= %>` pour l'affichage
- Éviter les helpers complexes dans les vues

### CSS/JavaScript
- Utiliser Tailwind CSS pour le styling
- Utiliser Stimulus pour l'interactivité
- Éviter le CSS/JS inline

## Sécurité

### Authentification
- Utiliser Devise pour l'authentification
- Toujours valider les permissions avec Pundit

### Données sensibles
- Utiliser Rails credentials pour les secrets
- Ne jamais commiter les secrets dans le code

### Validations
- Valider côté serveur (toujours)
- Valider côté client (amélioration UX)

## Performance

### Requêtes
- Utiliser `includes` pour éviter les N+1 queries
- Utiliser les scopes pour les requêtes réutilisables
- Indexer les colonnes fréquemment recherchées

### Background Jobs
- Utiliser Sidekiq pour les tâches longues
- Ne pas bloquer les requêtes HTTP avec des tâches lourdes

## Documentation

### Code
- Commenter le code complexe
- Utiliser des noms de variables/méthodes explicites
- Documenter les méthodes publiques

### API
- Documenter les endpoints API
- Fournir des exemples d'utilisation

