import { Controller } from "@hotwired/stimulus"

// Carousel infini avec défilement automatique continu pour l'annuaire
export default class extends Controller {
  static targets = ["track", "item"]

  connect() {
    this.isPaused = false
    this.speed = 1 // pixels par frame (ajustable, augmenté pour être plus visible)
    this.animationId = null
    this.position = 0
    this.originalItemCount = 0
    
    // Pause au survol
    this.element.addEventListener('mouseenter', () => this.pause())
    this.element.addEventListener('mouseleave', () => this.resume())
    
    // Gérer le resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
    
    // Attendre que le DOM soit prêt avant d'initialiser
    // Utiliser plusieurs tentatives pour s'assurer que les targets sont détectés
    this.initAttempts = 0
    this.tryInitialize()
  }

  tryInitialize() {
    this.initAttempts++
    
    if (!this.hasTrackTarget) {
      if (this.initAttempts < 10) {
        setTimeout(() => this.tryInitialize(), 100)
      } else {
        console.error("Annuaire carousel: track target non trouvé après 10 tentatives")
      }
      return
    }
    
    // Trouver les items manuellement si les targets ne sont pas détectés
    const items = this.trackTarget.querySelectorAll('[data-annuaire-carousel-target="item"]')
    
    if (items.length === 0) {
      if (this.initAttempts < 10) {
        setTimeout(() => this.tryInitialize(), 100)
      } else {
        console.error("Annuaire carousel: aucun item trouvé après 10 tentatives")
      }
      return
    }
    
    // Utiliser les items trouvés
    this.originalItemCount = items.length
    this.items = Array.from(items)
    
    // Utiliser un délai pour s'assurer que le layout est calculé
    setTimeout(() => {
      this.duplicateItems()
      // Attendre encore un peu pour que les clones soient rendus
      requestAnimationFrame(() => {
        this.startAnimation()
      })
    }, 200)
  }

  disconnect() {
    this.stopAnimation()
    window.removeEventListener('resize', this.handleResize)
  }

  duplicateItems() {
    if (!this.hasTrackTarget || !this.items || this.items.length === 0) return
    
    // Cloner tous les items pour créer l'effet infini
    // On clone 2 fois pour avoir assez d'items pour le défilement continu
    this.items.forEach(item => {
      const clone = item.cloneNode(true)
      // Ne pas ajouter le target pour éviter qu'ils soient comptés dans itemTargets
      clone.removeAttribute('data-annuaire-carousel-target')
      this.trackTarget.appendChild(clone)
    })
    
    // Cloner une deuxième fois pour plus de fluidité
    this.items.forEach(item => {
      const clone = item.cloneNode(true)
      clone.removeAttribute('data-annuaire-carousel-target')
      this.trackTarget.appendChild(clone)
    })
  }

  startAnimation() {
    if (this.animationId) return
    
    const animate = () => {
      if (!this.isPaused && this.hasTrackTarget && this.items && this.originalItemCount > 0) {
        // Défilement de droite vers gauche (position négative)
        this.position -= this.speed
        
        // Calculer la largeur totale d'un set d'items originaux
        const firstItem = this.items[0]
        if (firstItem) {
          const itemWidth = firstItem.offsetWidth || 200
          // Gap responsive : 2rem (32px) sur desktop, 1.5rem (24px) sur mobile
          const gap = window.innerWidth >= 768 ? 32 : 24
          const setWidth = (itemWidth + gap) * this.originalItemCount
          
          // Réinitialiser la position quand on a défilé d'un set complet
          // Cela crée l'effet infini sans saccade visible
          if (Math.abs(this.position) >= setWidth) {
            this.position = 0
          }
        }
        
        this.trackTarget.style.transform = `translateX(${this.position}px)`
      }
      
      this.animationId = requestAnimationFrame(animate)
    }
    
    this.animationId = requestAnimationFrame(animate)
  }

  stopAnimation() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
      this.animationId = null
    }
  }

  pause() {
    this.isPaused = true
  }

  resume() {
    this.isPaused = false
  }

  handleResize() {
    // Réinitialiser la position si nécessaire lors du resize
    // pour éviter les problèmes de layout
    if (this.hasTrackTarget && this.items && this.items.length > 0) {
      const itemWidth = this.items[0]?.offsetWidth || 0
      if (itemWidth > 0) {
        // Optionnel: réinitialiser la position
        // this.position = 0
      }
    }
  }
}

