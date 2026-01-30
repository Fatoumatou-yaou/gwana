import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lazy-video"
export default class extends Controller {
  static targets = ["iframe", "thumbnail"]
  static values = { started: Boolean }

  connect() {
    this.started = false
    
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.started) {
          this.loadVideo()
          this.started = true
        }
      })
    }, {
      threshold: 0.5
    })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  loadVideo() {
    const iframe = this.iframeTarget
    const thumbnail = this.hasThumbnailTarget ? this.thumbnailTarget : null
    const src = iframe.getAttribute("data-src")

    if (src && !iframe.src) {
      iframe.src = src
      
      if (thumbnail) {
        thumbnail.style.display = "none"
      }
      iframe.classList.remove("hidden")
      iframe.classList.add("block")
    }
  }
}

