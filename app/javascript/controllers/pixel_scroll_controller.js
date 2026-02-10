import { Controller } from "@hotwired/stimulus"

// Pixel Effect on Scroll Controller
// Crée un effet de pixellisation progressive des images au scroll
export default class extends Controller {
  static targets = ["container", "source", "canvas"]

  connect() {
    // Vérifier les préférences de mouvement réduit
    this.prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    
    // Sur mobile, on active l'effet mais avec des images plus petites
    this.isMobile = window.innerWidth < 768
    
    if (this.prefersReducedMotion) {
      // Afficher les images normalement sans effet
      this.showImagesNormally()
      return
    }

    // Initialiser les canvas pour chaque image
    this.imageData = new Map()
    this.initialized = new Set()
    this.ticking = false
    
    // Setup Intersection Observer pour le lazy loading
    this.setupIntersectionObserver()
    
    // Setup scroll handler avec throttling
    this.setupScrollHandler()
    
    // Setup click handlers pour le zoom
    this.setupClickHandlers()
  }

  disconnect() {
    // Nettoyer les event listeners
    if (this.scrollHandler) {
      window.removeEventListener('scroll', this.scrollHandler, { passive: true })
    }
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect()
    }
    // Fermer la modal si elle est ouverte
    this.closeZoom()
  }

  showImagesNormally() {
    // Afficher les images normalement sans effet pixel
    this.containerTargets.forEach((container, index) => {
      const source = container.querySelector('[data-pixel-scroll-target="source"]')
      const canvas = container.querySelector('[data-pixel-scroll-target="canvas"]')
      
      if (source && canvas) {
        // Remplacer le canvas par l'image normale
        const img = document.createElement('img')
        img.src = source.src
        img.className = "w-full h-auto cursor-pointer"
        img.addEventListener('click', () => {
          this.openZoom(index)
        })
        canvas.replaceWith(img)
      }
    })
  }

  setupIntersectionObserver() {
    // Observer pour initialiser les canvas uniquement quand ils entrent dans le viewport
    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const container = entry.target
          const index = this.containerTargets.indexOf(container)
          
          if (index !== -1 && !this.initialized.has(index)) {
            this.initializeCanvas(index)
            this.initialized.add(index)
          }
        }
      })
    }, {
      rootMargin: '100px' // Commencer à charger 100px avant que l'image soit visible
    })

    // Observer tous les containers
    this.containerTargets.forEach(container => {
      this.intersectionObserver.observe(container)
    })
  }

  initializeCanvas(index) {
    const container = this.containerTargets[index]
    const source = container.querySelector('[data-pixel-scroll-target="source"]')
    const canvas = container.querySelector('[data-pixel-scroll-target="canvas"]')
    
    if (!source || !canvas) return

    const img = new Image()
    img.crossOrigin = 'anonymous'
    
    img.onload = () => {
      // Calculer la taille du canvas en fonction de la largeur du container
      let containerWidth = container.offsetWidth || window.innerWidth
      
      // Sur mobile, réduire la taille pour voir l'effet pixel
      if (this.isMobile) {
        containerWidth = Math.min(containerWidth, 400) // Max 400px sur mobile
      }
      
      // Vérifier si un aspect-ratio est défini dans le style inline
      let displayWidth = containerWidth
      let displayHeight
      
      // Lire l'aspect-ratio depuis le style inline du canvas
      const aspectRatioAttr = canvas.getAttribute('style')
      let aspectRatioMatch = null
      if (aspectRatioAttr) {
        aspectRatioMatch = aspectRatioAttr.match(/aspect-ratio:\s*(\d+)\/(\d+)/)
      }
      
      if (aspectRatioMatch) {
        // Utiliser l'aspect-ratio défini (format "16/9", "4/3", etc.)
        const widthRatio = parseFloat(aspectRatioMatch[1])
        const heightRatio = parseFloat(aspectRatioMatch[2])
        displayHeight = (displayWidth * heightRatio) / widthRatio
      } else {
        // Utiliser l'aspect-ratio de l'image originale
        const aspectRatio = img.height / img.width
        displayHeight = displayWidth * aspectRatio
      }
      
      // Définir la taille d'affichage du canvas (CSS)
      canvas.style.width = `${displayWidth}px`
      canvas.style.height = `${displayHeight}px`
      
      // Définir la résolution interne du canvas (pour la qualité)
      // Sur mobile, réduire la résolution pour les performances
      const maxResolution = this.isMobile ? 800 : 1920
      const scale = Math.min(1, maxResolution / displayWidth)
      canvas.width = Math.floor(displayWidth * scale)
      canvas.height = Math.floor(displayHeight * scale)
      
      const ctx = canvas.getContext('2d')
      
      // Calculer comment dessiner l'image pour remplir le canvas avec l'aspect-ratio défini
      const canvasAspectRatio = displayWidth / displayHeight
      const imgAspectRatio = img.width / img.height
      
      let drawWidth, drawHeight, drawX, drawY
      
      if (imgAspectRatio > canvasAspectRatio) {
        // L'image est plus large que le canvas, on coupe les côtés (object-fit: cover)
        drawHeight = canvas.height
        drawWidth = drawHeight * imgAspectRatio
        drawX = (canvas.width - drawWidth) / 2
        drawY = 0
      } else {
        // L'image est plus haute que le canvas, on coupe le haut/bas (object-fit: cover)
        drawWidth = canvas.width
        drawHeight = drawWidth / imgAspectRatio
        drawX = 0
        drawY = (canvas.height - drawHeight) / 2
      }
      
      // Dessiner l'image dans le canvas pour remplir avec l'aspect-ratio défini
      ctx.drawImage(img, drawX, drawY, drawWidth, drawHeight)
      
      // Obtenir les données de l'image
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
      
      // Stocker les données pour éviter de les recalculer
      this.imageData.set(index, {
        imageData: imageData,
        width: canvas.width,
        height: canvas.height,
        displayWidth: displayWidth,
        displayHeight: displayHeight,
        isComplete: false // Flag pour savoir si l'image est déjà complètement affichée
      })
      
      // Initialiser avec 0% de révélation
      this.drawPixelatedImage(index, 0)
    }
    
    img.src = source.src
  }

  setupScrollHandler() {
    // Throttling avec requestAnimationFrame
    this.scrollHandler = () => {
      if (!this.ticking) {
        window.requestAnimationFrame(() => {
          this.updateAllImages()
          this.ticking = false
        })
        this.ticking = true
      }
    }
    
    window.addEventListener('scroll', this.scrollHandler, { passive: true })
    
    // Initialiser au chargement
    this.updateAllImages()
  }

  updateAllImages() {
    this.containerTargets.forEach((container, index) => {
      if (this.initialized.has(index) && this.imageData.has(index)) {
        const progress = this.calculateScrollProgress(container)
        
        // Si progress = 1, on a déjà affiché l'image complète, ne plus toucher
        const data = this.imageData.get(index)
        if (data && data.isComplete && progress >= 1) {
          return // Ne plus redessiner si l'image est déjà complète
        }
        
        this.drawPixelatedImage(index, progress)
        
        // Marquer comme complète si progress = 1
        if (progress >= 1 && data) {
          data.isComplete = true
        }
      }
    })
  }

  calculateScrollProgress(container) {
    const rect = container.getBoundingClientRect()
    const windowHeight = window.innerHeight
    const containerTop = rect.top
    const containerHeight = rect.height
    const containerBottom = containerTop + containerHeight
    
    // Calculer le progress basé sur la position de l'image dans le viewport
    // Progress = 0 : image complètement pixellisée (quand l'image entre dans le viewport)
    // Progress = 1 : image complètement normale (quand l'image est complètement dans le viewport)
    // Une fois progress = 1, on ne touche plus à rien (l'image reste affichée complètement)
    
    // Si l'image est complètement dans le viewport, progress = 1 (ne plus toucher)
    if (containerTop >= 0 && containerBottom <= windowHeight) {
      return 1
    }
    
    // Si l'image est complètement au-dessus du viewport, progress = 0
    if (containerBottom <= 0) {
      return 0
    }
    
    // Si l'image est complètement en-dessous du viewport, progress = 1 (déjà révélée)
    if (containerTop >= windowHeight) {
      return 1
    }
    
    // Zone de transition : calculer le progress linéairement
    // Progress augmente de 0 à 1 pendant que l'image entre dans le viewport
    // On utilise la position du haut de l'image par rapport au viewport
    let progress = 0
    
    if (containerTop < 0) {
      // Le haut de l'image est au-dessus du viewport, on commence la transition
      // Progress basé sur la partie visible de l'image
      const visibleHeight = containerBottom
      progress = visibleHeight / containerHeight
    } else {
      // Le haut de l'image est dans le viewport, on continue la transition
      // Progress basé sur combien de l'image est visible
      const visibleHeight = windowHeight - containerTop
      progress = Math.min(1, visibleHeight / containerHeight)
    }
    
    // S'assurer que progress est entre 0 et 1
    progress = Math.max(0, Math.min(1, progress))
    
    return progress
  }

  drawPixelatedImage(index, progress) {
    const data = this.imageData.get(index)
    if (!data) return

    const container = this.containerTargets[index]
    const canvas = container.querySelector('[data-pixel-scroll-target="canvas"]')
    if (!canvas) return

    const ctx = canvas.getContext('2d')
    const { imageData, width, height } = data
    
    // Taille des pixels (grille de 30x30 pour un bon compromis performance/effet)
    const pixelSize = 30
    const cols = Math.ceil(width / pixelSize)
    const rows = Math.ceil(height / pixelSize)
    
    // Si progress >= 1, dessiner l'image complète normalement (sans pixelisation)
    if (progress >= 1) {
      ctx.putImageData(imageData, 0, 0)
      return
    }
    
    // Si progress = 0, dessiner l'image complètement pixellisée
    if (progress <= 0) {
      // Dessiner tous les pixels
      for (let row = 0; row < rows; row++) {
        for (let col = 0; col < cols; col++) {
          const x = col * pixelSize
          const y = row * pixelSize
          
          const centerX = Math.min(x + pixelSize / 2, width - 1)
          const centerY = Math.min(y + pixelSize / 2, height - 1)
          
          const pixelIndex = (Math.floor(centerY) * width + Math.floor(centerX)) * 4
          
          const r = imageData.data[pixelIndex]
          const g = imageData.data[pixelIndex + 1]
          const b = imageData.data[pixelIndex + 2]
          const a = imageData.data[pixelIndex + 3]
          
          ctx.fillStyle = `rgba(${r}, ${g}, ${b}, ${a / 255})`
          ctx.fillRect(x, y, pixelSize, pixelSize)
        }
      }
      return
    }
    
    // Pour progress entre 0 et 1 : dessiner l'image normale puis masquer avec des pixels
    // Dessiner d'abord l'image complète en arrière-plan
    ctx.putImageData(imageData, 0, 0)
    
    // Calculer jusqu'à quelle ligne les pixels doivent disparaître (de haut en bas)
    // Progress = 0 : tous les pixels visibles (image complètement pixellisée)
    // Progress = 1 : aucun pixel visible (image complète normale)
    const revealedRows = Math.floor(progress * rows)
    
    // Dessiner les pixels par-dessus l'image pour masquer les parties non révélées
    // On dessine les pixels seulement pour les lignes qui ne sont pas encore révélées
    for (let row = revealedRows; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const x = col * pixelSize
        const y = row * pixelSize
        
        // Calculer la position dans les données de l'image
        const centerX = Math.min(x + pixelSize / 2, width - 1)
        const centerY = Math.min(y + pixelSize / 2, height - 1)
        
        const pixelIndex = (Math.floor(centerY) * width + Math.floor(centerX)) * 4
        
        // Récupérer la couleur moyenne du pixel pour créer l'effet pixel
        const r = imageData.data[pixelIndex]
        const g = imageData.data[pixelIndex + 1]
        const b = imageData.data[pixelIndex + 2]
        const a = imageData.data[pixelIndex + 3]
        
        // Dessiner le pixel par-dessus l'image
        ctx.fillStyle = `rgba(${r}, ${g}, ${b}, ${a / 255})`
        ctx.fillRect(x, y, pixelSize, pixelSize)
      }
    }
    
    // Pour la ligne de transition (ligne partiellement révélée)
    if (revealedRows < rows && progress > 0) {
      const partialRow = progress * rows - revealedRows
      if (partialRow > 0) {
        const row = revealedRows
        const pixelOpacity = 1 - partialRow // Opacité décroissante pour la transition
        
        for (let col = 0; col < cols; col++) {
          const x = col * pixelSize
          const y = row * pixelSize
          
          const centerX = Math.min(x + pixelSize / 2, width - 1)
          const centerY = Math.min(y + pixelSize / 2, height - 1)
          
          const pixelIndex = (Math.floor(centerY) * width + Math.floor(centerX)) * 4
          
          const r = imageData.data[pixelIndex]
          const g = imageData.data[pixelIndex + 1]
          const b = imageData.data[pixelIndex + 2]
          const a = imageData.data[pixelIndex + 3]
          
          // Pixel avec opacité réduite pour transition douce
          ctx.fillStyle = `rgba(${r}, ${g}, ${b}, ${(a / 255) * pixelOpacity})`
          ctx.fillRect(x, y, pixelSize, pixelSize)
        }
      }
    }
  }

  setupClickHandlers() {
    // Ajouter un event listener sur chaque canvas pour le zoom
    this.containerTargets.forEach((container, index) => {
      const canvas = container.querySelector('[data-pixel-scroll-target="canvas"]')
      if (canvas) {
        canvas.style.cursor = 'pointer'
        canvas.addEventListener('click', () => {
          this.openZoom(index)
        })
      }
    })
  }

  openZoom(index) {
    const container = this.containerTargets[index]
    const source = container.querySelector('[data-pixel-scroll-target="source"]')
    if (!source) return

    // Créer la modal plein écran
    const modal = document.createElement('div')
    modal.className = 'fixed inset-0 bg-black z-50 flex items-center justify-center'
    modal.id = 'photo-zoom-modal'
    
    // Image en plein écran
    const img = document.createElement('img')
    img.src = source.src
    img.className = 'max-w-full max-h-full object-contain'
    img.alt = 'Photo en plein écran'
    
    // Bouton retour (flèche)
    const backButton = document.createElement('button')
    backButton.className = 'absolute top-4 left-4 bg-white/90 hover:bg-white rounded-full p-3 shadow-lg transition-all duration-200 z-10'
    backButton.innerHTML = `
      <svg class="w-6 h-6 md:w-8 md:h-8 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
      </svg>
    `
    backButton.addEventListener('click', () => this.closeZoom())
    backButton.setAttribute('aria-label', 'Retour à la galerie')
    
    // Fermer avec Escape
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        this.closeZoom()
      }
    }
    document.addEventListener('keydown', handleEscape)
    modal._escapeHandler = handleEscape
    
    // Fermer en cliquant sur le fond
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        this.closeZoom()
      }
    })
    
    modal.appendChild(img)
    modal.appendChild(backButton)
    document.body.appendChild(modal)
    document.body.style.overflow = 'hidden' // Empêcher le scroll du body
    
    // Animation d'entrée
    requestAnimationFrame(() => {
      modal.style.opacity = '0'
      modal.style.transition = 'opacity 0.3s ease-in-out'
      requestAnimationFrame(() => {
        modal.style.opacity = '1'
      })
    })
  }

  closeZoom() {
    const modal = document.getElementById('photo-zoom-modal')
    if (modal) {
      // Animation de sortie
      modal.style.opacity = '0'
      setTimeout(() => {
        if (modal._escapeHandler) {
          document.removeEventListener('keydown', modal._escapeHandler)
        }
        document.body.style.overflow = '' // Réactiver le scroll
        modal.remove()
      }, 300)
    }
  }
}

