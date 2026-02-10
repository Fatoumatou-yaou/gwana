import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="custom-select"
export default class extends Controller {
  static targets = ["button", "menu", "input"]
  static values = { selected: String }

  connect() {
    this.isOpen = false
    this.selectedValue = this.inputTarget.value || ""
    this.updateButtonText()
    this.setupClickOutside()
  }

  disconnect() {
    this.removeClickOutside()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.isOpen = !this.isOpen
    this.updateMenuVisibility()
  }

  selectOption(event) {
    event.preventDefault()
    event.stopPropagation()
    const option = event.currentTarget
    const value = option.dataset.value
    const text = option.textContent.trim()
    
    this.selectedValue = value
    this.inputTarget.value = value
    this.isOpen = false
    this.updateMenuVisibility()
    this.updateButtonText(text)
    
    // Déclencher un événement change sur l'input pour les formulaires
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  updateButtonText(text = null) {
    if (!text) {
      // Si l'input est un select, utiliser les options
      if (this.inputTarget.tagName === 'SELECT' && this.inputTarget.options) {
      const selectedOption = this.inputTarget.options[this.inputTarget.selectedIndex]
      text = selectedOption ? selectedOption.textContent.trim() : this.buttonTarget.dataset.placeholder || "Sélectionnez..."
      } else {
        // Pour les hidden inputs, utiliser la valeur ou le placeholder
        text = this.inputTarget.value ? this.getTextFromValue(this.inputTarget.value) : this.buttonTarget.dataset.placeholder || "Sélectionnez..."
      }
    }
    
    // Preserve SVG if it exists
    const svg = this.buttonTarget.querySelector('svg')
    const buttonSpan = this.buttonTarget.querySelector('span')
    
    if (buttonSpan) {
      buttonSpan.textContent = text
    } else {
      this.buttonTarget.innerHTML = `<span>${text}</span>`
      if (svg) {
        this.buttonTarget.appendChild(svg)
      }
    }
  }

  getTextFromValue(value) {
    // Chercher dans le menu l'option correspondante à la valeur
    const menu = this.menuTarget
    if (menu) {
      const optionButton = menu.querySelector(`button[data-value="${value}"]`)
      if (optionButton) {
        return optionButton.textContent.trim()
      }
    }
    return this.buttonTarget.dataset.placeholder || "Sélectionnez..."
  }

  updateMenuVisibility() {
    if (this.isOpen) {
      this.menuTarget.classList.remove("hidden")
      // Scroll le bouton dans la vue si nécessaire
      this.buttonTarget.scrollIntoView({ behavior: "smooth", block: "nearest" })
    } else {
      this.menuTarget.classList.add("hidden")
    }
  }

  setupClickOutside() {
    this.handleClickOutside = (event) => {
      if (!this.element.contains(event.target) && this.isOpen) {
        this.isOpen = false
        this.updateMenuVisibility()
      }
    }
    document.addEventListener("click", this.handleClickOutside)
  }

  removeClickOutside() {
    if (this.handleClickOutside) {
      document.removeEventListener("click", this.handleClickOutside)
    }
  }
}

