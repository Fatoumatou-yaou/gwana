import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "iframe"]

  connect() {
    // Close modal on escape key
    document.addEventListener("keydown", this.handleEscape.bind(this))
    // Close modal on background click
    this.modalTarget.addEventListener("click", this.handleBackgroundClick.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this))
  }

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.youtubeModalUrlParam || event.currentTarget.dataset.url
    if (url) {
      this.iframeTarget.src = url
      this.modalTarget.classList.remove("hidden")
      document.body.style.overflow = "hidden"
    }
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.iframeTarget.src = ""
    document.body.style.overflow = ""
  }

  handleEscape(event) {
    if (event.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }

  handleBackgroundClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}

