import { Controller } from "@hotwired/stimulus"

// Déclenche une animation d'entrée (slideInUp, fadeInUp, etc.) quand la section entre dans le viewport.
// Respecte prefers-reduced-motion.
export default class extends Controller {
  static values = {
    animation: { type: String, default: "slideInUp" }
  }

  connect() {
    this.prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    if (this.prefersReducedMotion) {
      this.revealImmediately()
      return
    }
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersect(entries),
      { rootMargin: "0px 0px -60px 0px", threshold: 0.08 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  handleIntersect(entries) {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return
      if (this.element.dataset.sectionRevealAnimated === "true") return
      this.element.dataset.sectionRevealAnimated = "true"
      const animationClass = this.animationToClass(this.animationValue)
      this.element.classList.add("section-reveal-in", animationClass)
      this.observer.unobserve(this.element)
    })
  }

  animationToClass(name) {
    const map = {
      slideInUp: "section-reveal-slide-in-up",
      fadeInUp: "section-reveal-fade-in-up",
      fadeIn: "section-reveal-fade-in",
      slideInLeft: "section-reveal-slide-in-left",
      slideInRight: "section-reveal-slide-in-right"
    }
    return map[name] || map.slideInUp
  }

  revealImmediately() {
    this.element.classList.add("section-reveal-in", "section-reveal-fade-in")
  }
}
