import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"
import { Autoplay } from "swiper/modules"

export default class extends Controller {
  static values = { 
    loop: { type: Boolean, default: true }
  }

  connect() {
    const slidesCount = this.element.querySelectorAll('.swiper-slide').length
    
    this.swiper = new Swiper(this.element, {
      modules: [Autoplay],
      slidesPerView: 1,
      spaceBetween: 40,
      centeredSlides: true,
      autoplay: {
        delay: 4000,
        disableOnInteraction: false,
        pauseOnMouseEnter: true,
      },
      loop: this.loopValue && slidesCount > 1,
      loopAdditionalSlides: 1,
      speed: 1000,
      effect: 'slide',
    })
  }

  disconnect() {
    if (this.swiper) {
      this.swiper.destroy()
    }
  }
}

