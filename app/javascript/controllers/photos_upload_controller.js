import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error", "info", "preview"]
  static values = {
    maxFiles: { type: Number, default: 30 },
    maxFileSize: { type: Number, default: 2097152 }, // 2 Mo en bytes
    maxTotalSize: { type: Number, default: 62914560 }, // 60 Mo total (30 * 2 Mo)
    existingCount: { type: Number, default: 0 }
  }

  connect() {
    this.updateInfo()
    // Ajouter un listener sur le formulaire parent pour valider à la soumission
    const form = this.element.closest('form')
    if (form) {
      // Utiliser capture pour intercepter avant Turbo
      form.addEventListener('submit', (e) => this.submit(e), { capture: true })
    }
  }

  validate(event) {
    const files = Array.from(event.target.files || [])
    
    // Si aucun fichier sélectionné, ne rien faire
    if (files.length === 0) {
      this.hideError()
      this.updateInfo(0, 0)
      return true
    }
    
    const errors = []

    // Vérifier le nombre total de fichiers
    const totalCount = this.existingCountValue + files.length
    if (totalCount > this.maxFilesValue) {
      errors.push(`Vous ne pouvez pas sélectionner plus de ${this.maxFilesValue} photos au total. Vous avez déjà ${this.existingCountValue} photo(s) et vous essayez d'en ajouter ${files.length}.`)
    }

    // Vérifier chaque fichier
    let totalSize = 0
    files.forEach((file, index) => {
      // Vérifier que c'est bien un File object
      if (!(file instanceof File)) {
        errors.push(`Le fichier à l'index ${index + 1} n'est pas valide.`)
        return
      }
      
      // Vérifier la taille individuelle - IMPORTANT: bloquer si > 2 Mo
      if (file.size > this.maxFileSizeValue) {
        const sizeInMB = (file.size / 1048576).toFixed(2)
        errors.push(`La photo "${file.name}" dépasse 2 Mo (${sizeInMB} Mo).`)
      }

      // Vérifier le type
      const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/webp"]
      if (!allowedTypes.includes(file.type)) {
        errors.push(`Le fichier "${file.name}" n'est pas au format autorisé (JPEG, PNG, WebP).`)
      }

      // Calculer la taille totale uniquement pour les fichiers valides
      if (file.size <= this.maxFileSizeValue && allowedTypes.includes(file.type)) {
        totalSize += file.size
      }
    })

    // Vérifier la taille totale
    if (totalSize > this.maxTotalSizeValue) {
      const totalSizeMB = (totalSize / 1048576).toFixed(2)
      errors.push(`La taille totale des photos sélectionnées (${totalSizeMB} Mo) dépasse la limite.`)
    }

    if (errors.length > 0) {
      this.showError(errors.join(" "))
      event.target.value = "" // Réinitialiser la sélection
      console.error("Erreurs de validation:", errors)
      return false
    }

    // Tout est valide
    this.hideError()
    this.updateInfo(files.length, totalSize)
    
    // Logger pour le debugging
    console.log(`Photos validées: ${files.length} fichier(s)`, files.map(f => ({ name: f.name, size: f.size, type: f.type })))
    
    return true
  }

  showError(message) {
    if (this.hasErrorTarget) {
      const errorParagraph = this.errorTarget.querySelector('p')
      if (errorParagraph) {
        errorParagraph.textContent = message
      } else {
        this.errorTarget.textContent = message
      }
      this.errorTarget.classList.remove("hidden")
      this.errorTarget.classList.add("block")
      
      // Faire défiler vers l'erreur pour qu'elle soit visible
      setTimeout(() => {
        this.errorTarget.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }, 100)
    } else {
      // Fallback: afficher dans la console si le target n'existe pas
      console.error("Erreur photos upload:", message)
      alert(message) // Fallback ultime
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
      this.errorTarget.classList.remove("block")
      this.errorTarget.textContent = ""
    }
  }

  updateInfo(selectedCount = 0, totalSize = 0) {
    if (this.hasInfoTarget) {
      const remaining = this.maxFilesValue - this.existingCountValue - selectedCount
      let infoText = `${selectedCount} photo(s) sélectionnée(s)`
      
      if (totalSize > 0) {
        const sizeMB = (totalSize / 1048576).toFixed(2)
        infoText += ` (${sizeMB} Mo)`
      }
      
      if (remaining >= 0) {
        infoText += ` - ${remaining} photo(s) restante(s)`
      }
      
      this.infoTarget.textContent = infoText
    }
  }

  submit(event) {
    // Toujours vérifier les fichiers à la soumission, même si validate a été appelé
    if (this.hasInputTarget && this.inputTarget.files && this.inputTarget.files.length > 0) {
      const files = Array.from(this.inputTarget.files)
      
      // Logger pour le debugging
      console.log(`[SUBMIT] Soumission du formulaire avec ${files.length} fichier(s)`, files.map(f => ({ name: f.name, size: f.size, type: f.type, sizeMB: (f.size / 1048576).toFixed(2) })))
      
      // Vérifier que les fichiers sont bien des File objects
      const invalidFiles = files.filter(f => !(f instanceof File))
      if (invalidFiles.length > 0) {
        console.error('Fichiers invalides détectés:', invalidFiles)
        event.preventDefault()
        event.stopPropagation()
        this.showError("Certains fichiers ne sont pas valides. Veuillez réessayer.")
        return false
      }
      
      // Re-vérifier avant la soumission
      const totalCount = this.existingCountValue + files.length
      if (totalCount > this.maxFilesValue) {
        console.error(`[SUBMIT] Trop de photos: ${totalCount} > ${this.maxFilesValue}`)
        event.preventDefault()
        event.stopPropagation()
        this.showError(`Vous ne pouvez pas sélectionner plus de ${this.maxFilesValue} photos au total. Vous avez déjà ${this.existingCountValue} photo(s) et vous essayez d'en ajouter ${files.length}.`)
        return false
      }

      // Vérifier la taille de chaque fichier - BLOQUER si > 2 Mo
      const errors = []
      let totalSize = 0
      
      for (const file of files) {
        // Vérifier la taille - CRITIQUE: bloquer si > 2 Mo
        if (file.size > this.maxFileSizeValue) {
          const sizeInMB = (file.size / 1048576).toFixed(2)
          const errorMsg = `La photo "${file.name}" dépasse 2 Mo (${sizeInMB} Mo).`
          errors.push(errorMsg)
          console.error(`[SUBMIT] ${errorMsg}`)
        } else {
          totalSize += file.size
        }
        
        // Vérifier le type
        const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/webp"]
        if (!allowedTypes.includes(file.type)) {
          const errorMsg = `Le fichier "${file.name}" n'est pas au format autorisé.`
          errors.push(errorMsg)
          console.error(`[SUBMIT] ${errorMsg}`)
        }
      }
      
      // Vérifier la taille totale
      if (totalSize > this.maxTotalSizeValue) {
        const totalSizeMB = (totalSize / 1048576).toFixed(2)
        const errorMsg = `La taille totale des photos (${totalSizeMB} Mo) est trop importante.`
        errors.push(errorMsg)
        console.error(`[SUBMIT] ${errorMsg}`)
      }
      
      // Si des erreurs sont détectées, BLOQUER la soumission
      if (errors.length > 0) {
        console.error(`[SUBMIT] Erreurs détectées, blocage de la soumission:`, errors)
        event.preventDefault()
        event.stopPropagation()
        this.showError(errors.join(" "))
        // Faire défiler vers le haut pour voir l'erreur
        this.element.scrollIntoView({ behavior: 'smooth', block: 'start' })
        return false
      }
      
      console.log(`[SUBMIT] Validation OK, soumission autorisée`)
    }
    
    // Si on arrive ici, tout est OK, laisser le formulaire se soumettre normalement
    return true
  }
}

