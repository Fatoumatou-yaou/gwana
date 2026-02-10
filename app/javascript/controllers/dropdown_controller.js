import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
// Gère à la fois le hover (desktop) et le clic (mobile)
export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.isOpen = false
    this.hideTimeout = null
    this.setupClickOutside()
  }

  disconnect() {
    this.removeClickOutside()
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.isOpen = !this.isOpen
    this.updateMenuVisibility()
  }

  show() {
    // Pour le hover sur desktop
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
    this.isOpen = true
    this.updateMenuVisibility()
  }

  hide() {
    // Pour le hover sur desktop - avec délai pour permettre de se déplacer vers le menu
    this.hideTimeout = setTimeout(() => {
      this.isOpen = false
      this.updateMenuVisibility()
      this.hideTimeout = null
    }, 100)
  }

  updateMenuVisibility() {
    if (this.hasMenuTarget) {
      if (this.isOpen) {
        this.menuTarget.classList.remove("hidden")
        this.menuTarget.classList.add("block")
      } else {
        this.menuTarget.classList.add("hidden")
        this.menuTarget.classList.remove("block")
      }
    }
  }

  setupClickOutside() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  removeClickOutside() {
    if (this.boundHandleClickOutside) {
      document.removeEventListener("click", this.boundHandleClickOutside)
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && this.isOpen) {
      this.isOpen = false
      this.updateMenuVisibility()
    }
  }
}

