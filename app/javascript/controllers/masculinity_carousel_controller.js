import { Controller } from "@hotwired/stimulus"

// Premium 3D Carousel Controller for Masculinity Section
// Features: Smooth transitions, responsive, touch-enabled, keyboard navigation

export default class extends Controller {
  static targets = ["track", "card", "dot"]

  connect() {
    this.currentIndex = 0
    this.cardsPerView = this.getCardsPerView()
    this.totalCards = this.cardTargets.length
    // Calculate maxIndex - allow scrolling to see all cards
    // With 3 cards: mobile (1 per view) = maxIndex 2, tablet (1.5) = maxIndex 1, desktop (2.2) = maxIndex 0
    this.maxIndex = Math.max(0, this.totalCards - Math.ceil(this.cardsPerView))
    
    // Set card widths dynamically
    this.setCardWidths()
    
    // Initialize carousel
    this.updateCarousel()
    
    // Setup responsive handling
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
    
    // Setup keyboard navigation
    this.handleKeyboard = this.handleKeyboard.bind(this)
    document.addEventListener('keydown', this.handleKeyboard)
    
    // Setup touch/swipe gestures
    this.setupTouchHandlers()
    
    // Auto-play
    this.startAutoPlay()
  }
  
  // Set dynamic card widths based on cards per view
  setCardWidths() {
    if (!this.element || this.element.offsetWidth === 0) {
      // Wait for element to be rendered
      setTimeout(() => this.setCardWidths(), 100)
      return
    }
    
    const gap = 32 // gap-8 = 2rem = 32px
    const containerWidth = this.element.offsetWidth
    const gapPercentage = (gap / containerWidth) * 100
    const cardWidth = (100 - (gapPercentage * (this.cardsPerView - 1))) / this.cardsPerView
    
    this.cardTargets.forEach(card => {
      card.style.width = `${cardWidth}%`
      card.style.flexShrink = '0'
    })
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    document.removeEventListener('keydown', this.handleKeyboard)
    
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval)
    }
    
    if (this.trackTarget) {
      this.trackTarget.removeEventListener('touchstart', this.touchStart)
      this.trackTarget.removeEventListener('touchmove', this.touchMove)
      this.trackTarget.removeEventListener('touchend', this.touchEnd)
    }
  }

  // Get number of cards to show based on viewport
  getCardsPerView() {
    const width = window.innerWidth
    
    if (width < 768) {
      return 1 // Mobile: 1 card
    } else if (width < 1024) {
      return 1.5 // Tablet: 1.5 cards (peek effect)
    } else {
      return 2.2 // Desktop: 2.2 cards (peek effect)
    }
  }

  // Navigate to next slide
  next() {
    if (this.currentIndex < this.maxIndex) {
      this.currentIndex++
      this.updateCarousel()
    } else {
      // Loop back to start
      this.currentIndex = 0
      this.updateCarousel()
    }
  }

  // Navigate to previous slide
  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.updateCarousel()
    } else {
      // Loop to end
      this.currentIndex = this.maxIndex
      this.updateCarousel()
    }
  }

  // Go to specific slide
  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    
    if (index !== this.currentIndex && index <= this.maxIndex) {
      this.currentIndex = index
      this.updateCarousel()
    }
  }

  // Update carousel position and state
  updateCarousel() {
    if (!this.trackTarget || !this.element || this.element.offsetWidth === 0) {
      return
    }
    
    // Calculate offset - move by one card at a time
    const gap = 32 // gap-8 = 32px
    const containerWidth = this.element.offsetWidth
    const gapPercentage = (gap / containerWidth) * 100
    const cardWidthPercentage = (100 - (gapPercentage * (this.cardsPerView - 1))) / this.cardsPerView
    const offset = -this.currentIndex * (cardWidthPercentage + gapPercentage)
    
    // Apply transform with smooth transition
    this.trackTarget.style.transform = `translateX(${offset}%)`
    
    // Update dots
    this.updateDots()
    
    // Update card states for 3D effects
    this.updateCardStates()
  }

  // Update active dot indicator
  updateDots() {
    if (!this.hasDotTarget) return
    
    this.dotTargets.forEach((dot, index) => {
      if (index === this.currentIndex) {
        dot.classList.add('active')
        dot.classList.remove('bg-white/30', 'w-3')
        dot.classList.add('bg-white', 'w-8')
      } else {
        dot.classList.remove('active', 'bg-white', 'w-8')
        dot.classList.add('bg-white/30', 'w-3')
      }
    })
  }

  // Update card states for depth effect
  updateCardStates() {
    if (!this.hasCardTarget) return
    
    // Keep all cards fully visible and interactive
    this.cardTargets.forEach((card) => {
      card.style.opacity = '1'
      card.style.transform = 'scale(1)'
      card.style.pointerEvents = 'auto'
    })
  }

  // Handle window resize
  handleResize() {
    const newCardsPerView = this.getCardsPerView()
    
    if (newCardsPerView !== this.cardsPerView) {
      this.cardsPerView = newCardsPerView
      this.maxIndex = Math.max(0, this.totalCards - Math.ceil(this.cardsPerView))
      
      // Recalculate card widths
      this.setCardWidths()
      
      // Adjust current index if needed
      if (this.currentIndex > this.maxIndex) {
        this.currentIndex = this.maxIndex
      }
      
      // Small delay to ensure layout is updated
      setTimeout(() => {
        this.updateCarousel()
      }, 50)
    } else {
      // Even if cardsPerView hasn't changed, recalculate on resize
      this.setCardWidths()
      this.updateCarousel()
    }
  }

  // Handle keyboard navigation
  handleKeyboard(event) {
    // Only handle if carousel is in viewport
    if (!this.isInViewport()) return
    
    switch(event.key) {
      case 'ArrowLeft':
        event.preventDefault()
        this.previous()
        break
      case 'ArrowRight':
        event.preventDefault()
        this.next()
        break
    }
  }

  // Check if carousel is in viewport
  isInViewport() {
    if (!this.element) return false
    
    const rect = this.element.getBoundingClientRect()
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    )
  }

  // Setup touch/swipe handlers
  setupTouchHandlers() {
    if (!this.trackTarget) return
    
    let touchStartX = 0
    let touchEndX = 0
    
    this.touchStart = (event) => {
      touchStartX = event.changedTouches[0].screenX
    }
    
    this.touchMove = (event) => {
      touchEndX = event.changedTouches[0].screenX
    }
    
    this.touchEnd = () => {
      this.handleSwipe(touchStartX, touchEndX)
    }
    
    this.trackTarget.addEventListener('touchstart', this.touchStart, { passive: true })
    this.trackTarget.addEventListener('touchmove', this.touchMove, { passive: true })
    this.trackTarget.addEventListener('touchend', this.touchEnd, { passive: true })
  }

  // Handle swipe gesture
  handleSwipe(startX, endX) {
    const swipeThreshold = 50
    const diff = startX - endX
    
    if (Math.abs(diff) > swipeThreshold) {
      if (diff > 0) {
        // Swipe left - next
        this.next()
      } else {
        // Swipe right - previous
        this.previous()
      }
    }
  }

  // Auto-play functionality
  startAutoPlay(interval = 4000) {
    this.autoPlayInterval = setInterval(() => {
      if (this.currentIndex >= this.maxIndex) {
        this.currentIndex = 0
      } else {
        this.currentIndex++
      }
      this.updateCarousel()
    }, interval)
  }

  stopAutoPlay() {
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval)
      this.autoPlayInterval = null
    }
  }

  // Pause auto-play on hover
  pauseAutoPlay() {
    this.stopAutoPlay()
  }

  // Resume auto-play
  resumeAutoPlay() {
    if (!this.autoPlayInterval) {
      this.startAutoPlay()
    }
  }
}

