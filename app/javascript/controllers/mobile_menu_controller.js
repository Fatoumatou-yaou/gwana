import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.menuVisible = false
  }

  toggle() {
    this.menuVisible = !this.menuVisible
    this.updateMenuVisibility()
  }

  updateMenuVisibility() {
    if (this.menuVisible) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("block")
    } else {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.classList.remove("block")
    }
  }
}

