import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form"]

  connect() {
    this.hideModal()
  }

  show(event) {
    event.preventDefault()
    event.stopPropagation()
    this.showModal()
  }

  hide(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    this.hideModal()
  }

  showModal() {
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  hideModal() {
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
    
    // Réinitialiser le formulaire
    if (this.hasFormTarget) {
      this.formTarget.reset()
    }
  }
}

