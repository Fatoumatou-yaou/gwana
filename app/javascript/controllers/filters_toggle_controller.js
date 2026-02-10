import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters-toggle"
export default class extends Controller {
  static targets = ["panel", "overlay", "button"]

  connect() {
    this.isOpen = false
    this.setupKeyboardListener()
    this.setupSelectHandlers()
  }

  disconnect() {
    this.removeKeyboardListener()
    this.removeSelectHandlers()
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.updateVisibility()
  }

  close() {
    if (this.isOpen) {
      this.isOpen = false
      this.updateVisibility()
    }
  }

  updateVisibility() {
    if (this.isOpen) {
      this.panelTarget.classList.remove("hidden")
      this.panelTarget.classList.add("flex")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("hidden")
      }
      document.body.style.overflow = "hidden"
      // Animation d'entrée
      requestAnimationFrame(() => {
        this.panelTarget.classList.remove("opacity-0", "translate-x-full")
        this.panelTarget.classList.add("opacity-100", "translate-x-0")
        if (this.hasOverlayTarget) {
          this.overlayTarget.classList.remove("opacity-0")
          this.overlayTarget.classList.add("opacity-100")
        }
      })
    } else {
      // Animation de sortie
      this.panelTarget.classList.remove("opacity-100", "translate-x-0")
      this.panelTarget.classList.add("opacity-0", "translate-x-full")
      if (this.hasOverlayTarget) {
        this.overlayTarget.classList.remove("opacity-100")
        this.overlayTarget.classList.add("opacity-0")
      }
      // Attendre la fin de l'animation avant de cacher
      setTimeout(() => {
        this.panelTarget.classList.remove("flex")
        this.panelTarget.classList.add("hidden")
        if (this.hasOverlayTarget) {
          this.overlayTarget.classList.add("hidden")
        }
        document.body.style.overflow = ""
      }, 300)
    }
  }

  setupSelectHandlers() {
    // Gérer les selects pour qu'ils ne sortent pas du panneau
    this.handleSelectFocus = (event) => {
      if (!this.isOpen) return
      
      const select = event.target
      if (select.tagName === "SELECT") {
        // S'assurer que le select est visible dans le viewport
        const panel = this.panelTarget
        const selectRect = select.getBoundingClientRect()
        const panelRect = panel.getBoundingClientRect()
        
        // Si le select est trop bas, scroller pour le rendre visible
        if (selectRect.bottom > panelRect.bottom - 200) {
          select.scrollIntoView({ behavior: "smooth", block: "center" })
        }
      }
    }

    // Écouter les événements focus sur les selects
    if (this.hasPanelTarget) {
      this.panelTarget.addEventListener("focus", this.handleSelectFocus, true)
    }
  }

  removeSelectHandlers() {
    if (this.hasPanelTarget && this.handleSelectFocus) {
      this.panelTarget.removeEventListener("focus", this.handleSelectFocus, true)
    }
  }

  setupKeyboardListener() {
    this.handleEscape = (event) => {
      if (event.key === "Escape" && this.isOpen) {
        this.close()
      }
    }
    document.addEventListener("keydown", this.handleEscape)
  }

  removeKeyboardListener() {
    if (this.handleEscape) {
      document.removeEventListener("keydown", this.handleEscape)
    }
  }
}

