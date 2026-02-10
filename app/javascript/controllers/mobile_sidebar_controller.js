import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-sidebar"
export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.sidebarVisible = false
  }

  toggle() {
    this.sidebarVisible = !this.sidebarVisible
    this.updateVisibility()
  }

  close() {
    this.sidebarVisible = false
    this.updateVisibility()
  }

  updateVisibility() {
    if (this.sidebarVisible) {
      this.sidebarTarget.classList.remove("-translate-x-full")
      this.sidebarTarget.classList.add("translate-x-0")
      this.overlayTarget.classList.remove("hidden")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
      this.sidebarTarget.classList.remove("translate-x-0")
      this.overlayTarget.classList.add("hidden")
    }
  }
}

