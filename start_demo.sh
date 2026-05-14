#!/bin/bash

# Script de démarrage pour la démonstration GWANA
# Configure les emails pour fonctionner en local

echo "🚀 Démarrage de la plateforme GWANA pour démonstration"
echo "📧 Configuration des emails en mode développement"
echo ""

# Variables d'environnement pour les emails
export USE_LETTER_OPENER=true

# Démarrer le serveur Rails
echo "🔧 Démarrage du serveur Rails..."
echo "📬 Les emails seront visibles sur : http://localhost:3000/letter_opener"
echo ""
echo "Pour arrêter : Ctrl+C"
echo ""

bin/rails server