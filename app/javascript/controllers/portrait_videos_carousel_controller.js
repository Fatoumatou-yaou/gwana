import { Controller } from "@hotwired/stimulus"

// Carousel pour les vidéos portraits avec navigation par flèches et swipe
export default class extends Controller {
  static targets = ["track", "card", "prevButton", "nextButton", "videoFrame", "container", "trackInner"]
  static values = { 
    videoUrl: String,
    index: Number
  }

  connect() {
    this.currentIndex = 0
    this.totalCards = this.cardTargets.length
    
    // Setup responsive handling
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
    
    // Calculer cardsPerView initial selon la taille de l'écran
    this.calculateCardsPerView()
    
    // Setup touch/swipe handlers
    this.setupTouchHandlers()
    
    // Initialiser la position après un petit délai pour que le layout soit calculé
    setTimeout(() => {
      this.updateCarousel()
      this.updateNavigation()
    }, 100)
    
    // Marquer la première card comme active
    this.updateActiveCard(0)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    
    if (this.trackTarget) {
      this.trackTarget.removeEventListener('touchstart', this.touchStart)
      this.trackTarget.removeEventListener('touchmove', this.touchMove)
      this.trackTarget.removeEventListener('touchend', this.touchEnd)
    }
  }

  // Navigate to next slide
  next() {
    if (this.currentIndex < this.maxIndex) {
      this.currentIndex++
      this.updateCarousel()
    }
  }

  // Navigate to previous slide
  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.updateCarousel()
    }
  }

  // Update carousel position
  updateCarousel() {
    if (!this.trackTarget || !this.hasContainerTarget || !this.hasTrackInnerTarget || this.cardTargets.length === 0) {
      return
    }
    
    const container = this.containerTarget
    if (!container || container.offsetWidth === 0) {
      return
    }
    
    // Utiliser la largeur réelle de la première card
    const firstCard = this.cardTargets[0]
    if (!firstCard) {
      return
    }
    
    // Attendre que la card ait une largeur calculée
    const cardWidth = firstCard.offsetWidth
    if (cardWidth === 0) {
      // Réessayer après un court délai si la largeur n'est pas encore calculée
      setTimeout(() => this.updateCarousel(), 50)
      return
    }
    
    // Calculer la largeur d'une carte + gap
    const gap = 24 // gap-6 = 1.5rem = 24px
    const offset = -this.currentIndex * (cardWidth + gap)
    
    // Appliquer la transformation sur le div flex interne
    this.trackInnerTarget.style.transform = `translateX(${offset}px)`
    
    // Mettre à jour la navigation
    this.updateNavigation()
  }

  // Update navigation buttons visibility
  updateNavigation() {
    if (!this.hasPrevButtonTarget || !this.hasNextButtonTarget) return
    
    // Afficher les flèches seulement s'il y a plus de 4 vidéos
    if (this.totalCards > this.cardsPerView) {
      this.prevButtonTarget.classList.remove("hidden")
      this.nextButtonTarget.classList.remove("hidden")
      
      // Désactiver les boutons aux extrémités
      if (this.currentIndex === 0) {
        this.prevButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
        this.prevButtonTarget.disabled = true
      } else {
        this.prevButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
        this.prevButtonTarget.disabled = false
      }
      
      if (this.currentIndex >= this.maxIndex) {
        this.nextButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
        this.nextButtonTarget.disabled = true
      } else {
        this.nextButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
        this.nextButtonTarget.disabled = false
      }
    } else {
      this.prevButtonTarget.classList.add("hidden")
      this.nextButtonTarget.classList.add("hidden")
    }
  }

  // Calculate cards per view based on screen size
  calculateCardsPerView() {
    const width = window.innerWidth
    if (width < 768) {
      this.cardsPerView = 1
    } else if (width < 1024) {
      this.cardsPerView = 2
    } else if (width < 1280) {
      this.cardsPerView = 3
    } else {
      this.cardsPerView = 4
    }
    
    this.maxIndex = Math.max(0, this.totalCards - this.cardsPerView)
    
    // Ajuster currentIndex si nécessaire
    if (this.currentIndex > this.maxIndex) {
      this.currentIndex = this.maxIndex
    }
  }

  // Handle window resize
  handleResize() {
    // Recalculer cardsPerView selon la taille de l'écran
    this.calculateCardsPerView()
    
    // Mettre à jour après un petit délai pour que le layout soit calculé
    setTimeout(() => {
      this.updateCarousel()
      this.updateNavigation()
    }, 50)
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

  // Load video in the iframe
  loadVideo(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const button = event.currentTarget
    const videoUrl = button.dataset.portraitVideosCarouselVideoUrlParam
    const index = parseInt(button.dataset.portraitVideosCarouselIndexParam)
    
    if (!videoUrl) {
      console.error('Video URL introuvable')
      return
    }
    
    if (!this.hasVideoFrameTarget) {
      console.error('Video frame target introuvable')
      return
    }
    
    // Faire défiler le carousel vers la card cliquée si elle n'est pas visible
    const isVisible = index >= this.currentIndex && index < this.currentIndex + this.cardsPerView
    
    if (!isVisible) {
      // Ajuster currentIndex pour afficher la card cliquée
      this.currentIndex = Math.min(index, this.maxIndex)
      
      // Mettre à jour le carousel après un petit délai pour s'assurer que le layout est prêt
      setTimeout(() => {
        this.updateCarousel()
      }, 10)
    }
    
    // Charger la nouvelle vidéo
    this.videoFrameTarget.src = videoUrl
    this.updateActiveCard(index)
  }

  // Update active card styling
  updateActiveCard(activeIndex) {
    this.cardTargets.forEach((card, index) => {
      const button = card.querySelector('button')
      if (button) {
        if (index === activeIndex) {
          button.classList.add('border-purple-700', 'border-2')
          button.classList.remove('border-gray-200')
        } else {
          button.classList.remove('border-purple-700', 'border-2')
          button.classList.add('border-gray-200')
        }
      }
    })
  }
}

