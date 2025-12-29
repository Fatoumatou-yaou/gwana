import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "photoField", "videoField"]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const mediaType = this.selectTarget.value

    if (this.hasPhotoFieldTarget) {
      this.photoFieldTarget.style.display = mediaType === "photo" ? "block" : "none"
    }

    if (this.hasVideoFieldTarget) {
      this.videoFieldTarget.style.display = mediaType === "video" ? "block" : "none"
    }
  }
}

