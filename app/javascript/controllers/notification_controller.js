import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ajouter une classe pour l'animation d'entrée
    this.element.classList.add("translate-x-0", "opacity-100")
    
    // Fermer automatiquement après 5 secondes
    setTimeout(() => {
      this.close()
    }, 5000)
  }

  close() {
    // Ajouter les classes pour l'animation de sortie
    this.element.classList.add("translate-x-full", "opacity-0")
    
    // Supprimer l'élément après l'animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
} 