class ApplicationDecorator < Draper::Decorator
  # Délègue toutes les méthodes du modèle à l'objet décoré
  # Cela permet d'accéder aux attributs du modèle (email, profile, etc.)
  # tout en ajoutant des méthodes de présentation dans les decorators spécifiques
  delegate_all

  # Define methods for all decorated objects.
  # Helpers are accessed through `helpers` (aka `h`). For example:
  #
  #   def percent_amount
  #     h.number_to_percentage object.amount, precision: 2
  #   end
end
