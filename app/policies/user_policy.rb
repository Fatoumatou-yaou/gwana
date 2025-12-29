class UserPolicy < ApplicationPolicy
  # Accès au profil - tous les utilisateurs connectés
  def profile?
    user.present?
  end

  # Accès aux demandes de mentorat - tous les utilisateurs connectés
  def mentorship_requests?
   admin_or_gwana?
  end

  # Accès aux demandes reçues en tant que mentor - seulement les gwanas
  def mentor_requests?
    gwana?
  end

  # Accès à la liste des membres (gwanas) - seulement les gwanas et admins
  def members?
    admin?
  end

  # Accès aux articles - tous les utilisateurs connectés peuvent voir les articles publics
  def articles?
    user?
  end

  # Accès au dashboard admin - seulement les admins
  def admin_dashboard?
    admin?
  end
end

