import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="article-reader"
export default class extends Controller {
  static targets = ["progress", "tocLink", "heading"]

  connect() {
    this.updateProgress()
    this.setupScrollListeners()
  }

  disconnect() {
    this.removeScrollListeners()
  }

  setupScrollListeners() {
    this.scrollHandler = this.throttledScroll.bind(this)
    window.addEventListener('scroll', this.scrollHandler, { passive: true })
  }

  removeScrollListeners() {
    if (this.scrollHandler) {
      window.removeEventListener('scroll', this.scrollHandler)
    }
  }

  throttledScroll = (() => {
    let ticking = false
    return () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          this.updateProgress()
          this.updateActiveTocLink()
          ticking = false
        })
        ticking = true
      }
    }
  })()

  updateProgress() {
    if (!this.hasProgressTarget) return

    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    const scrollHeight = document.documentElement.scrollHeight - window.innerHeight
    const scrollPercent = Math.min((scrollTop / scrollHeight) * 100, 100)

    this.progressTarget.style.width = scrollPercent + '%'
  }

  updateActiveTocLink() {
    if (!this.hasTocLinkTarget || !this.hasHeadingTarget) return

    const scrollPosition = window.scrollY + 150 // Offset for header
    let currentActiveIndex = -1

    this.headingTargets.forEach((heading, index) => {
      const headingTop = heading.offsetTop
      const headingBottom = headingTop + heading.offsetHeight

      if (scrollPosition >= headingTop && scrollPosition < headingBottom) {
        currentActiveIndex = index
      }
    })

    this.tocLinkTargets.forEach((link, index) => {
      link.classList.toggle('active', index === currentActiveIndex)
    })
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }

  scrollToHeading(event) {
    event.preventDefault()
    const targetId = event.currentTarget.getAttribute('href')
    const targetElement = document.querySelector(targetId)

    if (targetElement) {
      const offsetTop = targetElement.offsetTop - 120 // Account for fixed header and some padding
      window.scrollTo({
        top: offsetTop,
        behavior: 'smooth'
      })

      // Highlight the clicked link briefly
      this.tocLinkTargets.forEach(link => link.classList.remove('active'))
      event.currentTarget.classList.add('active')
      setTimeout(() => event.currentTarget.classList.remove('active'), 1000)
    }
  }
}
