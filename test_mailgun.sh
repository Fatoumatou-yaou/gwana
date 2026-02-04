#!/bin/bash
# Script de test pour vérifier la configuration Mailgun

cd ~/apps/gwana
MASTER_KEY=$(cat config/credentials/production.key)

echo "=========================================="
echo "TEST CONFIGURATION MAILGUN"
echo "=========================================="
echo ""

echo "1. Vérification des credentials Mailgun..."
RAILS_MASTER_KEY="$MASTER_KEY" RAILS_ENV=production bundle exec rails runner "
  creds = Rails.application.credentials.dig(:mailgun)
  if creds
    puts '✅ Credentials Mailgun trouvés:'
    puts '  SMTP Server: ' + (creds[:smtp_server] || 'non défini')
    puts '  SMTP Port: ' + (creds[:smtp_port] || 'non défini')
    puts '  SMTP Login: ' + (creds[:smtp_login] || 'non défini')
    puts '  SMTP Password: ' + (creds[:smtp_password] ? creds[:smtp_password][0..10] + '...' : 'non défini')
    puts '  Domain: ' + (creds[:domain] || 'non défini')
  else
    puts '❌ Credentials Mailgun non trouvés'
    exit 1
  end
"
echo ""

echo "2. Vérification de la configuration ActionMailer..."
RAILS_MASTER_KEY="$MASTER_KEY" RAILS_ENV=production bundle exec rails runner "
  puts 'Delivery method: ' + ActionMailer::Base.delivery_method.to_s
  puts 'Perform deliveries: ' + ActionMailer::Base.perform_deliveries.to_s
  puts 'Raise delivery errors: ' + ActionMailer::Base.raise_delivery_errors.to_s
  puts ''
  puts 'SMTP Settings:'
  ActionMailer::Base.smtp_settings.each do |key, value|
    if key == :password
      puts \"  #{key}: #{value ? value[0..10] + '...' : 'nil'}\"
    else
      puts \"  #{key}: #{value}\"
    end
  end
  puts ''
  puts 'Default from: ' + ActionMailer::Base.default[:from].to_s
  puts 'Default reply_to: ' + ActionMailer::Base.default[:reply_to].to_s
"
echo ""

echo "3. Test d'envoi d'email..."
RAILS_MASTER_KEY="$MASTER_KEY" RAILS_ENV=production bundle exec rails runner "
  # Créer un utilisateur temporaire pour le test ou utiliser un existant
  test_email = 'fatoumatouyaou@gmail.com'
  user = User.find_by(email: test_email) || User.first
  
  if user
    puts \"Test d'envoi à: #{user.email}\"
    begin
      UserMailer.send_credentials(user, 'test123').deliver_now
      puts '✅ Email envoyé avec succès'
      puts 'Vérifiez dans votre boîte mail: ' + test_email
      puts 'Vérifiez aussi dans Mailgun dashboard > Sending > Logs'
    rescue => e
      puts '❌ ERREUR lors de l\\'envoi:'
      puts e.message
      puts ''
      puts 'Backtrace:'
      puts e.backtrace.first(5)
    end
  else
    puts '⚠️  Aucun utilisateur trouvé'
    puts 'Création d\\'un utilisateur temporaire pour le test...'
    begin
      temp_user = User.create!(
        email: test_email,
        first_name: 'Test',
        last_name: 'User',
        password: 'TempPassword123!',
        password_confirmation: 'TempPassword123!',
        profile: :gwana
      )
      UserMailer.send_credentials(temp_user, 'test123').deliver_now
      puts '✅ Email envoyé avec succès à: ' + test_email
      puts 'Vérifiez dans votre boîte mail'
      puts 'Vérifiez aussi dans Mailgun dashboard > Sending > Logs'
    rescue => e
      puts '❌ ERREUR: ' + e.message
    end
  end
"
echo ""

echo "=========================================="
echo "TEST TERMINÉ"
echo "=========================================="
echo ""
echo "Si l'email a été envoyé, vérifiez dans:"
echo "  - Mailgun dashboard > Sending > Logs"
echo "  - La boîte de réception de l'utilisateur"
echo ""

