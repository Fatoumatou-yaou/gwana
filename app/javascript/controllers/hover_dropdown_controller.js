import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hover-dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.hideTimeout = null
  }

  show() {
    // Clear any pending hide timeout
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
    
    if (this.hasMenuTarget) {
      this.menuTarget.classList.remove("hidden")
    }
  }

  hide() {
    // Add a small delay before hiding to allow moving to the menu
    this.hideTimeout = setTimeout(() => {
      if (this.hasMenuTarget) {
        this.menuTarget.classList.add("hidden")
      }
      this.hideTimeout = null
    }, 100)
  }

  disconnect() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }
  }
}

