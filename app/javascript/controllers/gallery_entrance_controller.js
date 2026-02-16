import { Controller } from "@hotwired/stimulus"

// Animations d'entrée artistiques pour la galerie (mobile principalement, variées type Awwwards)
export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.isMobile = window.innerWidth < 768
    this.prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    if (this.prefersReducedMotion) {
      this.revealAll()
      return
    }
    if (!this.hasCardTarget) return
    this.entranceEffects = [
      "gallery-entrance-fade-up",
      "gallery-entrance-scale",
      "gallery-entrance-slide-left",
      "gallery-entrance-slide-right",
      "gallery-entrance-reveal",
      "gallery-entrance-blur"
    ]
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersect(entries),
      { rootMargin: "0px 0px -40px 0px", threshold: 0.1 }
    )
    this.cardTargets.forEach((card) => this.observer.observe(card))
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  handleIntersect(entries) {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return
      const card = entry.target
      if (card.dataset.galleryEntranceAnimated === "true") return
      card.dataset.galleryEntranceAnimated = "true"
      const index = this.cardTargets.indexOf(card)
      const effect = this.entranceEffects[index % this.entranceEffects.length]
      card.style.animationDelay = `${(index % 6) * 0.07}s`
      card.classList.add("gallery-entrance-in", effect)
      this.observer.unobserve(card)
    })
  }

  revealAll() {
    this.cardTargets.forEach((card) => {
      card.classList.add("gallery-entrance-in", "gallery-entrance-fade-up")
    })
  }
}
