# Configuration Active Storage avec Hetzner Object Storage

Ce guide explique comment configurer Active Storage pour utiliser Hetzner Object Storage en production, permettant de stocker vos fichiers PDF et images de manière sécurisée et scalable.

## 📋 Prérequis

- Compte Hetzner Cloud actif
- Bucket Object Storage créé dans Hetzner Cloud Console
- Clés d'accès (Access Key ID et Secret Access Key) générées

## 🔧 Étapes de configuration

### 1. Créer un Bucket Object Storage sur Hetzner

1. Connectez-vous à [Hetzner Cloud Console](https://console.hetzner.com)
2. Allez dans **Object Storage** > **Buckets**
3. Cliquez sur **Create Bucket**
4. Choisissez :
   - **Nom du bucket** : `gwana-production` (ou votre nom préféré)
   - **Région** : `hel1` (Helsinki), `nbg1` (Nuremberg) ou `fsn1` (Falkenstein)
   - **Type** : Standard
5. Notez le nom du bucket et la région choisie

### 2. Générer les clés d'accès

1. Dans Hetzner Cloud Console, allez dans **Object Storage** > **Access Keys**
2. Cliquez sur **Generate Access Key**
3. **IMPORTANT** : Copiez immédiatement l'**Access Key ID** et le **Secret Access Key**
   - Le Secret Access Key ne sera affiché qu'une seule fois !
4. Notez ces informations de manière sécurisée

### 3. Configurer les credentials Rails

Ajoutez les credentials Hetzner dans vos credentials Rails :

```bash
EDITOR="code --wait" rails credentials:edit
```

Ajoutez la section suivante :

```yaml
hetzner:
  object_storage_access_key_id: votre_access_key_id
  object_storage_secret_access_key: votre_secret_access_key
  object_storage_region: hel1  # ou nbg1, fsn1 selon votre choix
  object_storage_bucket: gwana-production  # nom de votre bucket
```

### 4. Activer Hetzner Object Storage dans storage.yml

Décommentez la section `hetzner` dans `config/storage.yml` :

```yaml
hetzner:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:hetzner, :object_storage_access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:hetzner, :object_storage_secret_access_key) %>
  region: <%= Rails.application.credentials.dig(:hetzner, :object_storage_region) || "hel1" %>
  bucket: <%= Rails.application.credentials.dig(:hetzner, :object_storage_bucket) %>
  endpoint: https://<%= Rails.application.credentials.dig(:hetzner, :object_storage_region) || "hel1" %>.your-objectstorage.com
  force_path_style: true
```

### 5. Configurer l'environnement de production

Dans `config/environments/production.rb`, Active Storage utilisera automatiquement le service défini par la variable d'environnement `ACTIVE_STORAGE_SERVICE`.

Pour activer Hetzner Object Storage, définissez cette variable sur votre serveur :

```bash
export ACTIVE_STORAGE_SERVICE=hetzner
```

Ou dans votre fichier `.env` ou configuration de déploiement :

```bash
ACTIVE_STORAGE_SERVICE=hetzner
```

### 6. Migrer les fichiers existants (si nécessaire)

Si vous avez déjà des fichiers en stockage local et que vous souhaitez les migrer vers Hetzner Object Storage :

```bash
# En production
RAILS_ENV=production rails console

# Dans la console Rails
ActiveStorage::Blob.find_each do |blob|
  next if blob.service_name == 'hetzner'
  
  # Télécharger depuis le service actuel
  file = blob.download
  
  # Réattacher au nouveau service
  blob.service_name = 'hetzner'
  blob.service.upload(blob.key, file)
  blob.save
end
```

## 💰 Coûts estimés

Hetzner Object Storage facture :
- **Stockage** : ~0,02 €/Go/mois
- **Transfert sortant** : ~0,01 €/Go
- **Requêtes** : Gratuites jusqu'à un certain seuil

**Exemple pour 10 Go de fichiers PDF :**
- Stockage : 10 Go × 0,02 € = **0,20 €/mois**
- Transfert : Variable selon le trafic

## 🔒 Sécurité

### Permissions du bucket

Par défaut, les fichiers sont privés. Pour permettre l'accès public aux fichiers (si nécessaire) :

1. Dans Hetzner Cloud Console, allez dans votre bucket
2. Configurez les **CORS** et **Policies** selon vos besoins
3. Pour les fichiers privés (recommandé pour les PDFs), utilisez les URLs signées :

```ruby
# Dans votre code Rails
url = rails_blob_path(identity_document, disposition: "attachment")
# ou pour une URL signée temporaire
url = identity_document.service_url(expires_in: 1.hour)
```

### URLs signées pour les PDFs

Pour les documents d'identité (PDFs sensibles), utilisez toujours des URLs signées avec expiration :

```ruby
# Exemple dans un controller
def show_document
  @request = GwanaNetworkRequest.find(params[:id])
  redirect_to @request.identity_document.service_url(expires_in: 5.minutes)
end
```

## 🧪 Tester la configuration

### En développement (local)

1. Créez un fichier `.env` avec :
   ```bash
   ACTIVE_STORAGE_SERVICE=hetzner
   ```

2. Testez l'upload :
   ```bash
   rails console
   ```
   ```ruby
   # Tester l'upload d'un PDF
   test_request = GwanaNetworkRequest.new(
     first_name: "Test",
     last_name: "User",
     email: "test@example.com"
   )
   
   # Attacher un fichier de test
   test_request.identity_document.attach(
     io: File.open("test.pdf"),
     filename: "test.pdf",
     content_type: "application/pdf"
   )
   
   # Vérifier que le fichier est bien uploadé
   test_request.identity_document.attached? # => true
   test_request.identity_document.service_name # => "hetzner"
   ```

### En production

1. Déployez avec `ACTIVE_STORAGE_SERVICE=hetzner`
2. Testez l'upload d'un PDF via l'interface
3. Vérifiez dans Hetzner Cloud Console que le fichier apparaît dans le bucket

## 🔄 Fallback vers stockage local

Si vous souhaitez garder le stockage local comme fallback, vous pouvez utiliser le service `mirror` :

```yaml
# Dans storage.yml
mirror:
  service: Mirror
  primary: hetzner
  mirrors: [local]
```

Puis dans `production.rb` :
```ruby
config.active_storage.service = :mirror
```

## 📝 Notes importantes

1. **Backup** : Hetzner Object Storage offre une redondance intégrée, mais pensez à mettre en place des backups réguliers de votre base de données (qui contient les métadonnées des fichiers)

2. **Performance** : Les fichiers sont servis directement depuis Hetzner Object Storage, ce qui libère votre serveur web

3. **Migration** : Si vous migrez depuis un stockage local, prévoyez un temps de migration pour les fichiers existants

4. **Monitoring** : Surveillez l'utilisation du stockage dans Hetzner Cloud Console pour éviter les surprises de facturation

## 🐛 Dépannage

### Erreur "Access Denied"

- Vérifiez que les credentials sont corrects dans `rails credentials:edit`
- Vérifiez que le bucket existe et que les clés d'accès ont les bonnes permissions

### Erreur "Endpoint not found"

- Vérifiez que la région dans les credentials correspond à celle du bucket
- Vérifiez le format de l'endpoint dans `storage.yml`

### Les fichiers ne s'uploadent pas

- Vérifiez que `ACTIVE_STORAGE_SERVICE=hetzner` est bien défini
- Vérifiez les logs Rails : `tail -f log/production.log`
- Testez la connexion depuis la console Rails

## 📚 Ressources

- [Documentation Hetzner Object Storage](https://docs.hetzner.com/storage/object-storage/)
- [Documentation Rails Active Storage](https://guides.rubyonrails.org/active_storage_overview.html)
- [Guide S3-compatible storage](https://edgeguides.rubyonrails.org/active_storage_overview.html#s3-service-amazon-s3-and-s3-compatible-apis)

