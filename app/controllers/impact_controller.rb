class ImpactController < ApplicationController
  layout "slim"

  def index
    # Les événements sont définis statiquement pour l'instant
    # Si besoin, on pourra créer un modèle Event plus tard
    @events = [
      {
        type: "caravane",
        title: "Caravane de sensibilisation à Maradi",
        description: "Organisation d'une caravane de sensibilisation sur l'éducation des filles et l'autonomisation des femmes dans la région de Maradi.",
        date: "2024",
        location: "Maradi",
        participants: 150,
        icon: "🚐"
      },
      {
        type: "caravane",
        title: "Caravane de sensibilisation à Tahoua",
        description: "Caravane de sensibilisation sur l'importance de l'éducation et de l'autonomisation des femmes dans la région de Tahoua.",
        date: "2024",
        location: "Tahoua",
        participants: 120,
        icon: "🚐"
      },
      {
        type: "caravane",
        title: "Caravane de sensibilisation à Dosso",
        description: "Caravane de sensibilisation sur l'éducation des filles et l'autonomisation des femmes dans la région de Dosso.",
        date: "2024",
        location: "Dosso",
        participants: 130,
        icon: "🚐"
      },
      {
        type: "atelier",
        title: "Ateliers de formation et développement des compétences",
        description: "Plus de 100 ateliers organisés pour développer les compétences des jeunes filles et femmes dans divers domaines.",
        date: "2023-2024",
        location: "Multi-régions",
        participants: 500,
        icon: "🎓"
      },
      {
        type: "sensibilisation",
        title: "Sensibilisation des communautés",
        description: "Plus de 50 communautés sensibilisées sur l'importance de l'éducation et de l'autonomisation des femmes.",
        date: "2023-2024",
        location: "Multi-régions",
        participants: 2000,
        icon: "🌍"
      },
      {
        type: "mentorat",
        title: "Programmes de mentorat",
        description: "Programmes de mentorat pour accompagner plus de 500 jeunes filles dans leur parcours éducatif et professionnel.",
        date: "2023-2024",
        location: "Multi-régions",
        participants: 500,
        icon: "👥"
      }
    ]
  end
end

