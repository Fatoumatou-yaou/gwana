#!/bin/bash
# Script de test Mailgun en local

echo "=========================================="
echo "TEST MAILGUN EN LOCAL"
echo "=========================================="
echo ""

echo "1. Vérification des credentials Mailgun..."
bundle exec rails runner "
  creds = Rails.application.credentials.dig(:mailgun)
  if creds
    puts '✅ Credentials Mailgun trouvés:'
    puts '  SMTP Server: ' + (creds[:smtp_server] || 'non défini')
    puts '  Domain: ' + (creds[:domain] || 'non défini')
    puts '  API Key: ' + (creds[:api_key] ? creds[:api_key][0..20] + '...' : 'non défini')
  else
    puts '❌ Credentials Mailgun non trouvés'
    puts 'Vérifiez config/credentials/development.key ou config/master.key'
    exit 1
  end
"
echo ""

echo "2. Test avec ActionMailer (mode test par défaut)..."
bundle exec rails runner "
  user = User.first || User.create!(
    email: 'fatoumatouyaou@gmail.com',
    first_name: 'Test',
    last_name: 'User',
    password: 'TempPassword123!',
    password_confirmation: 'TempPassword123!',
    profile: :gwana
  )
  
  puts \"Création d'un email avec UserMailer...\"
  mail = UserMailer.send_credentials(user, 'test123')
  puts 'Email créé:'
  puts '  From: ' + mail.from.first.to_s
  puts '  To: ' + mail.to.first.to_s
  puts '  Subject: ' + mail.subject
  puts ''
  puts 'Mode de livraison: ' + ActionMailer::Base.delivery_method.to_s
  puts 'Perform deliveries: ' + ActionMailer::Base.perform_deliveries.to_s
"
echo ""

echo "3. Test avec Mailgun API (USE_MAILGUN_API=true)..."
USE_MAILGUN_API=true bundle exec rails runner "
  puts 'Mode de livraison: ' + ActionMailer::Base.delivery_method.to_s
  puts 'Perform deliveries: ' + ActionMailer::Base.perform_deliveries.to_s
  puts ''
  
  user = User.find_by(email: 'fatoumatouyaou@gmail.com') || User.first
  if user
    puts \"Test d'envoi à: #{user.email}\"
    begin
      UserMailer.send_credentials(user, 'test123').deliver_now
      puts '✅ Email envoyé via Mailgun API'
      puts 'Vérifiez dans votre boîte mail: fatoumatouyaou@gmail.com'
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
  end
"
echo ""

echo "=========================================="
echo "TEST TERMINÉ"
echo "=========================================="
echo ""
echo "Pour tester manuellement dans la console Rails:"
echo "  USE_MAILGUN_API=true rails console"
echo "  > user = User.first"
echo "  > UserMailer.send_credentials(user, 'test123').deliver_now"
echo ""

