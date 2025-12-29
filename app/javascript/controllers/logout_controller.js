import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = { logoutUrl: String }

  connect() {
    // S'assurer que le modal est bien caché au départ
    this.hideModal()
  }

  show(event) {
    event.preventDefault()
    event.stopPropagation()
    this.showModal()
  }

  confirm() {
    // Fermer le modal d'abord
    this.hideModal()
    
    // Créer un formulaire pour la déconnexion
    const url = this.logoutUrlValue || "/users/sign_out"
    const form = document.createElement("form")
    form.method = "POST"
    form.action = url
    form.style.display = "none"
    
    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = "delete"
    form.appendChild(methodInput)
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }
    
    document.body.appendChild(form)
    form.submit()
  }

  cancel() {
    this.hideModal()
  }

  showModal() {
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    document.body.style.overflow = "hidden"
  }

  hideModal() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    document.body.style.overflow = ""
  }
}

