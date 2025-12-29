import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hero"
export default class extends Controller {
  static targets = ["image", "text", "overlay", "cta"]

  connect() {
    // Vérifier les préférences de mouvement réduit
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    
    if (!prefersReducedMotion) {
      // Animation d'entrée séquentielle pour les éléments texte
      this.animateTextElements()
      
      // Parallaxe au scroll
      this.setupParallax()
    } else {
      // Si mouvement réduit, afficher tout immédiatement sans animation
      this.showAllElementsImmediately()
    }
  }

  showAllElementsImmediately() {
    // Afficher tous les éléments immédiatement sans animation
    this.textTargets.forEach((target) => {
      target.classList.add("opacity-100", "translate-y-0")
      target.classList.remove("opacity-0", "translate-y-8")
    })
    
    if (this.hasCtaTarget) {
      this.ctaTargets.forEach((cta) => {
        cta.classList.add("opacity-100", "scale-100")
        cta.classList.remove("opacity-0", "scale-95")
      })
    }
  }

  animateTextElements() {
    // Animation séquentielle des spans dans le h2
    const h2Element = this.element.querySelector("h2[data-hero-target='text']")
    if (h2Element) {
      const spans = h2Element.querySelectorAll("span")
      if (spans.length > 0) {
        spans.forEach((span, index) => {
          setTimeout(() => {
            span.classList.add("opacity-100", "translate-y-0")
            span.classList.remove("opacity-0", "translate-y-8")
          }, index * 200 + 100)
        })
      }
      // Animer le h2 lui-même
      setTimeout(() => {
        h2Element.classList.add("opacity-100", "translate-y-0")
        h2Element.classList.remove("opacity-0", "translate-y-8")
      }, 300)
    }

    // Délai progressif pour les autres éléments texte (sauf h2)
    let textIndex = 0
    this.textTargets.forEach((target) => {
      // Skip h2 car on l'a déjà traité avec ses spans
      if (target.tagName === "H2") return
      
      setTimeout(() => {
        target.classList.add("opacity-100", "translate-y-0")
        target.classList.remove("opacity-0", "translate-y-8")
      }, 800 + (textIndex * 150))
      textIndex++
    })

    // Animation pour les CTA avec un délai supplémentaire
    setTimeout(() => {
      if (this.hasCtaTarget) {
        this.ctaTargets.forEach((cta) => {
          cta.classList.add("opacity-100", "scale-100")
          cta.classList.remove("opacity-0", "scale-95")
        })
      }
    }, 1200)
  }

  setupParallax() {
    // Parallaxe subtile pour l'image au scroll (optimisé avec requestAnimationFrame et throttling)
    if (this.hasImageTarget) {
      let ticking = false
      let lastScrollY = 0
      
      const updateParallax = () => {
        const scrolled = window.pageYOffset || window.scrollY
        
        // Throttling : ne mettre à jour que si le scroll a changé significativement
        if (Math.abs(scrolled - lastScrollY) < 1) {
          ticking = false
          return
        }
        
        lastScrollY = scrolled
        const rate = scrolled * 0.3
        
        if (scrolled < window.innerHeight) {
          this.imageTarget.style.transform = `translateY(${rate}px) scale(1.05)`
        } else {
          this.imageTarget.style.transform = `translateY(${window.innerHeight * 0.3}px) scale(1.05)`
        }
        
        ticking = false
      }
      
      window.addEventListener("scroll", () => {
        if (!ticking) {
          window.requestAnimationFrame(updateParallax)
          ticking = true
        }
      }, { passive: true })
    }
  }
}

