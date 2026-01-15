import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-step-form"
export default class extends Controller {
  static targets = ["step", "progressBar", "stepIndicator", "nextButton", "submitButton"]
  static values = { 
    currentStep: { type: Number, default: 1 },
    totalSteps: { type: Number, default: 4 }
  }

  connect() {
    this.showStep(this.currentStepValue)
    this.updateProgress()
    this.updateButtons()
    this.setupFormValidation()
  }

  setupFormValidation() {
    const form = this.element.closest('form')
    if (form) {
      form.addEventListener('submit', (event) => {
        // Valider toutes les étapes avant de soumettre
        const originalStep = this.currentStepValue
        let allValid = true
        let firstInvalidStep = null
        
        for (let step = 1; step <= this.totalStepsValue; step++) {
          // Valider l'étape sans changer l'état visuel
          const stepElement = this.stepTargets[step - 1]
          if (stepElement && !this.validateStep(step, stepElement)) {
            allValid = false
            if (firstInvalidStep === null) {
              firstInvalidStep = step
            }
          }
        }
        
        if (!allValid) {
          event.preventDefault()
          event.stopPropagation()
          // Aller à la première étape avec erreur
          if (firstInvalidStep) {
            this.currentStepValue = firstInvalidStep
            this.showStep(firstInvalidStep)
            this.updateProgress()
            this.updateButtons()
            this.scrollToTop()
          }
          return false
        }
        
        // Restaurer l'étape originale si tout est valide
        this.currentStepValue = originalStep
        return true
      })
    }
  }

  validateStep(stepNumber, stepElement) {
    if (!stepElement) return true

    let isValid = true
    const invalidFields = []

    // Validation selon l'étape (même logique que validateCurrentStep mais sans modifier l'état)
    if (stepNumber === 1) {
      const firstName = stepElement.querySelector('input[name*="[first_name]"], input[name*="first_name"]')
      const lastName = stepElement.querySelector('input[name*="[last_name]"], input[name*="last_name"]')
      const email = stepElement.querySelector('input[type="email"], input[name*="[email]"], input[name*="email"]')
      
      if (firstName && !firstName.value.trim()) {
        isValid = false
        invalidFields.push({ field: firstName, message: "Le prénom est requis" })
      }
      if (lastName && !lastName.value.trim()) {
        isValid = false
        invalidFields.push({ field: lastName, message: "Le nom est requis" })
      }
      if (email) {
        const emailValue = email.value.trim()
        if (!emailValue) {
          isValid = false
          invalidFields.push({ field: email, message: "L'email est requis" })
        } else {
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
          if (!emailRegex.test(emailValue)) {
            isValid = false
            invalidFields.push({ field: email, message: "Format d'email invalide" })
          }
        }
      }
      const phone = stepElement.querySelector('input[name*="[phone]"], input[name*="phone"]')
      if (phone && phone.value.trim()) {
        const phoneValue = phone.value.trim().replace(/\D/g, '')
        if (phoneValue.length !== 8) {
          isValid = false
          invalidFields.push({ field: phone, message: "Le téléphone doit contenir exactement 8 chiffres" })
        }
      }
    } else if (stepNumber === 2) {
      const region = stepElement.querySelector('select[name="region_id"], select[name*="[region_id]"]')
      if (region && !region.value) {
        isValid = false
        invalidFields.push({ field: region, message: "La région est requise" })
      }
    } else if (stepNumber === 3) {
      const profession = stepElement.querySelector('input[name*="[profession]"], input[name*="profession"]')
      const experiences = stepElement.querySelector('textarea[name*="[experiences]"], textarea[name*="experiences"]')
      const formations = stepElement.querySelector('textarea[name*="[formations]"], textarea[name*="formations"]')
      const bio = stepElement.querySelector('textarea[name*="[bio]"], textarea[name*="bio"]')
      
      if (profession && !profession.value.trim()) {
        isValid = false
        invalidFields.push({ field: profession, message: "La profession est requise" })
      }
      if (experiences && !experiences.value.trim()) {
        isValid = false
        invalidFields.push({ field: experiences, message: "Les expériences sont requises" })
      }
      if (formations && !formations.value.trim()) {
        isValid = false
        invalidFields.push({ field: formations, message: "Les formations sont requises" })
      }
      if (bio && !bio.value.trim()) {
        isValid = false
        invalidFields.push({ field: bio, message: "La bio est requise" })
      }
    } else if (stepNumber === 4) {
      const photo = stepElement.querySelector('input[type="file"][name*="[photo]"], input[type="file"][name*="photo"]')
      const identityDoc = stepElement.querySelector('input[type="file"][name*="[identity_document]"], input[type="file"][name*="identity_document"]')
      
      if (photo && photo.hasAttribute('required')) {
        const hasFile = photo.files && photo.files.length > 0
        const hasExistingImage = stepElement.querySelector('img[src*="photo"]') !== null
        if (!hasFile && !hasExistingImage) {
          isValid = false
          invalidFields.push({ field: photo, message: "La photo est requise" })
        }
      }
      
      if (identityDoc && identityDoc.hasAttribute('required')) {
        const hasFile = identityDoc.files && identityDoc.files.length > 0
        if (!hasFile) {
          isValid = false
          invalidFields.push({ field: identityDoc, message: "La carte d'identité est requise" })
        }
      }
    }

    // Marquer les champs invalides
    invalidFields.forEach(item => {
      const field = item.field || item
      const message = item.message || null
      
      if (field && field.offsetParent !== null) {
        field.classList.add("border-red-500")
        if (message) {
          this.showFieldError(field, message)
        }
      }
    })

    return isValid
  }

  next() {
    if (this.currentStepValue < this.totalStepsValue) {
      if (this.validateCurrentStep()) {
        this.currentStepValue++
        this.showStep(this.currentStepValue)
        this.updateProgress()
        this.scrollToTop()
      }
    }
  }

  previous() {
    if (this.currentStepValue > 1) {
      this.currentStepValue--
      this.showStep(this.currentStepValue)
      this.updateProgress()
      this.scrollToTop()
    }
  }

  goToStep(event) {
    const step = parseInt(event.currentTarget.dataset.step)
    if (step >= 1 && step <= this.totalStepsValue && step <= this.currentStepValue) {
      this.currentStepValue = step
      this.showStep(this.currentStepValue)
      this.updateProgress()
      this.scrollToTop()
    }
  }

  showStep(stepNumber) {
    this.stepTargets.forEach((step, index) => {
      if (index + 1 === stepNumber) {
        step.classList.remove("hidden")
        step.classList.add("block")
      } else {
        step.classList.remove("block")
        step.classList.add("hidden")
      }
    })
  }

  updateProgress() {
    const progress = (this.currentStepValue / this.totalStepsValue) * 100
    
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${progress}%`
    }

    if (this.hasStepIndicatorTarget) {
      this.stepIndicatorTargets.forEach((indicator, index) => {
        const stepNumber = index + 1
        // Retirer toutes les classes d'état
        indicator.classList.remove("bg-purple-700", "text-white", "bg-gray-200", "text-gray-600", "bg-purple-500")
        
        if (stepNumber < this.currentStepValue) {
          // Étape complétée
          indicator.classList.add("bg-purple-500", "text-white")
        } else if (stepNumber === this.currentStepValue) {
          // Étape active
          indicator.classList.add("bg-purple-700", "text-white")
        } else {
          // Étape en attente
          indicator.classList.add("bg-gray-200", "text-gray-600")
        }
      })
    }
  }

  validateCurrentStep() {
    const currentStepElement = this.stepTargets[this.currentStepValue - 1]
    if (!currentStepElement) return true

    let isValid = true
    const invalidFields = []

    // Validation selon l'étape
    if (this.currentStepValue === 1) {
      // Étape 1 : Tous les champs requis avec validation de format
      const firstName = currentStepElement.querySelector('input[name*="[first_name]"], input[name*="first_name"]')
      const lastName = currentStepElement.querySelector('input[name*="[last_name]"], input[name*="last_name"]')
      const email = currentStepElement.querySelector('input[type="email"], input[name*="[email]"], input[name*="email"]')
      const phone = currentStepElement.querySelector('input[name*="[phone]"], input[name*="phone"]')
      
      // Validation prénom
      if (firstName && !firstName.value.trim()) {
        isValid = false
        invalidFields.push({ field: firstName, message: "Le prénom est requis" })
      }
      
      // Validation nom
      if (lastName && !lastName.value.trim()) {
        isValid = false
        invalidFields.push({ field: lastName, message: "Le nom est requis" })
      }
      
      // Validation email avec format
      if (email) {
        const emailValue = email.value.trim()
        if (!emailValue) {
          isValid = false
          invalidFields.push({ field: email, message: "L'email est requis" })
        } else {
          // Validation du format email
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
          if (!emailRegex.test(emailValue)) {
            isValid = false
            invalidFields.push({ field: email, message: "Format d'email invalide" })
          }
        }
      }
      
      // Validation téléphone si rempli (format 8 chiffres)
      if (phone && phone.value.trim()) {
        const phoneValue = phone.value.trim().replace(/\D/g, '') // Enlever tout sauf les chiffres
        if (phoneValue.length !== 8) {
          isValid = false
          invalidFields.push({ field: phone, message: "Le téléphone doit contenir exactement 8 chiffres" })
        }
      }
    } else if (this.currentStepValue === 2) {
      // Étape 2 : Région requise
      const region = currentStepElement.querySelector('select[name="region_id"], select[name*="[region_id]"]')
      if (region && !region.value) {
        isValid = false
        invalidFields.push({ field: region, message: "La région est requise" })
      }
    } else if (this.currentStepValue === 3) {
      // Étape 3 : Tous les champs requis
      const profession = currentStepElement.querySelector('input[name*="[profession]"], input[name*="profession"]')
      const experiences = currentStepElement.querySelector('textarea[name*="[experiences]"], textarea[name*="experiences"]')
      const formations = currentStepElement.querySelector('textarea[name*="[formations]"], textarea[name*="formations"]')
      const bio = currentStepElement.querySelector('textarea[name*="[bio]"], textarea[name*="bio"]')
      
      if (profession && !profession.value.trim()) {
        isValid = false
        invalidFields.push({ field: profession, message: "La profession est requise" })
      }
      if (experiences && !experiences.value.trim()) {
        isValid = false
        invalidFields.push({ field: experiences, message: "Les expériences sont requises" })
      }
      if (formations && !formations.value.trim()) {
        isValid = false
        invalidFields.push({ field: formations, message: "Les formations sont requises" })
      }
      if (bio && !bio.value.trim()) {
        isValid = false
        invalidFields.push({ field: bio, message: "La bio est requise" })
      }
    } else if (this.currentStepValue === 4) {
      // Étape 4 : Photo requise, identity_document si présent
      const photo = currentStepElement.querySelector('input[type="file"][name*="[photo]"], input[type="file"][name*="photo"]')
      const identityDoc = currentStepElement.querySelector('input[type="file"][name*="[identity_document]"], input[type="file"][name*="identity_document"]')
      
      // Vérifier si le fichier a été sélectionné (pour les nouveaux fichiers)
      if (photo && photo.hasAttribute('required')) {
        const hasFile = photo.files && photo.files.length > 0
        // Vérifier s'il y a une image existante affichée
        const hasExistingImage = currentStepElement.querySelector('img[src*="photo"]') !== null
        if (!hasFile && !hasExistingImage) {
          isValid = false
          invalidFields.push({ field: photo, message: "La photo est requise" })
        }
      }
      
      if (identityDoc && identityDoc.hasAttribute('required')) {
        const hasFile = identityDoc.files && identityDoc.files.length > 0
        if (!hasFile) {
          isValid = false
          invalidFields.push({ field: identityDoc, message: "La carte d'identité est requise" })
        }
      }
    }

    // Marquer les champs invalides et afficher les messages d'erreur
    invalidFields.forEach(item => {
      const field = item.field || item
      const message = item.message || null
      
      if (field && field.offsetParent !== null) {
        field.classList.add("border-red-500")
        
        // Afficher un message d'erreur si fourni
        if (message) {
          this.showFieldError(field, message)
        }
        
        const removeError = () => {
          field.classList.remove("border-red-500")
          this.hideFieldError(field)
        }
        field.addEventListener("input", removeError, { once: true })
        field.addEventListener("change", removeError, { once: true })
      }
    })

    if (!isValid && invalidFields.length > 0) {
      const firstInvalid = invalidFields.find(item => {
        const field = item.field || item
        return field && field.offsetParent !== null
      }) || invalidFields[0]
      
      if (firstInvalid) {
        const field = firstInvalid.field || firstInvalid
        if (field) {
          field.scrollIntoView({ behavior: "smooth", block: "center" })
          field.focus()
        }
      }
    }

    return isValid
  }

  showFieldError(field, message) {
    // Retirer l'erreur existante si présente
    this.hideFieldError(field)
    
    // Créer le message d'erreur
    const errorDiv = document.createElement("div")
    errorDiv.className = "mt-1 text-sm text-red-600 flex items-center gap-1 field-error-message"
    errorDiv.innerHTML = `<span class="text-red-500">⚠</span>${message}`
    
    // Insérer après le champ
    field.parentNode.insertBefore(errorDiv, field.nextSibling)
  }

  hideFieldError(field) {
    // Retirer le message d'erreur existant
    const errorMessage = field.parentNode.querySelector(".field-error-message")
    if (errorMessage) {
      errorMessage.remove()
    }
  }

  scrollToTop() {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  currentStepValueChanged() {
    this.showStep(this.currentStepValue)
    this.updateProgress()
    this.updateButtons()
  }

  updateButtons() {
    const isLastStep = this.currentStepValue === this.totalStepsValue
    
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.classList.toggle("hidden", isLastStep)
    }
    
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.classList.toggle("hidden", !isLastStep)
    }
  }

  validatePhone(event) {
    const phoneField = event.target
    // Enlever tous les caractères non numériques
    const originalValue = phoneField.value
    phoneField.value = phoneField.value.replace(/\D/g, '')
    // Limiter à 8 caractères
    if (phoneField.value.length > 8) {
      phoneField.value = phoneField.value.substring(0, 8)
    }
    // Retirer l'erreur si le format est correct
    if (phoneField.value.length === 8) {
      phoneField.classList.remove("border-red-500")
      this.hideFieldError(phoneField)
    } else if (phoneField.value.length > 0 && phoneField.value.length < 8) {
      // Afficher une erreur si le téléphone est partiellement rempli
      phoneField.classList.add("border-red-500")
      this.showFieldError(phoneField, "Le téléphone doit contenir exactement 8 chiffres")
    }
  }

  validateEmail(event) {
    const emailField = event.target
    const emailValue = emailField.value.trim()
    
    if (emailValue) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (emailRegex.test(emailValue)) {
        emailField.classList.remove("border-red-500")
        this.hideFieldError(emailField)
      } else {
        emailField.classList.add("border-red-500")
        this.showFieldError(emailField, "Format d'email invalide")
      }
    } else if (emailField.hasAttribute('required')) {
      emailField.classList.add("border-red-500")
      this.showFieldError(emailField, "L'email est requis")
    }
  }

  validateRequiredField(event) {
    const field = event.target
    const value = field.value.trim()
    const isRequired = field.hasAttribute('required')
    
    if (isRequired && !value) {
      field.classList.add("border-red-500")
      const fieldName = this.getFieldLabel(field)
      this.showFieldError(field, `${fieldName} est requis`)
    } else {
      field.classList.remove("border-red-500")
      this.hideFieldError(field)
    }
  }

  validateFileField(event) {
    const fileField = event.target
    const isRequired = fileField.hasAttribute('required')
    
    if (isRequired) {
      const hasFile = fileField.files && fileField.files.length > 0
      const hasExistingFile = fileField.closest('[data-multi-step-form-target="step"]')?.querySelector('img[src*="photo"], input[data-existing-file="true"]') !== null
      
      if (!hasFile && !hasExistingFile) {
        fileField.classList.add("border-red-500")
        const fieldName = this.getFieldLabel(fileField)
        this.showFieldError(fileField, `${fieldName} est requis`)
      } else {
        fileField.classList.remove("border-red-500")
        this.hideFieldError(fileField)
      }
    }
  }

  getFieldLabel(field) {
    // Essayer de trouver le label associé
    const id = field.id
    if (id) {
      const label = document.querySelector(`label[for="${id}"]`)
      if (label) {
        // Retirer l'étoile et les balises HTML
        return label.textContent.replace(/\s*\*.*$/, '').trim() || "Ce champ"
      }
    }
    
    // Essayer de trouver le label précédent
    const label = field.closest('div')?.querySelector('label')
    if (label) {
      return label.textContent.replace(/\s*\*.*$/, '').trim() || "Ce champ"
    }
    
    return "Ce champ"
  }
}

