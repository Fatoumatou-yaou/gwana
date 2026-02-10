import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-cascade"
export default class extends Controller {
  static targets = ["region", "department", "commune"]

  connect() {
    this.setupEventListeners()
    this.loadInitialValues()
  }

  async loadInitialValues() {
    // If region is already selected, load departments
    if (this.hasRegionTarget && this.regionTarget.value) {
      const regionId = this.regionTarget.value
      
      // Store selected department value if exists
      if (this.hasDepartmentTarget && this.departmentTarget.value) {
        this.departmentTarget.dataset.selectedValue = this.departmentTarget.value
      }
      
      await this.onRegionChange({ target: this.regionTarget })
      
      // If department is already selected, load communes
      if (this.hasDepartmentTarget && this.departmentTarget.value) {
        // Store selected commune value if exists
        if (this.hasCommuneTarget && this.communeTarget.value) {
          this.communeTarget.dataset.selectedValue = this.communeTarget.value
        }
        
        await this.onDepartmentChange({ target: this.departmentTarget })
      }
    }
  }

  setupEventListeners() {
    if (this.hasRegionTarget) {
      this.regionTarget.addEventListener("change", this.onRegionChange.bind(this))
    }

    if (this.hasDepartmentTarget) {
      this.departmentTarget.addEventListener("change", this.onDepartmentChange.bind(this))
    }
  }

  async onRegionChange(event) {
    const regionId = event?.target?.value || event

    // Reset department and commune
    this.resetSelect(this.departmentTarget)
    this.resetSelect(this.communeTarget)

    if (!regionId) {
      return
    }

    try {
      const response = await fetch(`/api/departments?region_id=${regionId}`)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const departments = await response.json()

      this.populateSelect(this.departmentTarget, departments)
      
      // If there was a previously selected department, try to restore it
      if (this.departmentTarget.dataset.selectedValue) {
        this.departmentTarget.value = this.departmentTarget.dataset.selectedValue
        delete this.departmentTarget.dataset.selectedValue
        if (this.departmentTarget.value) {
          await this.onDepartmentChange({ target: this.departmentTarget })
        }
      }
    } catch (error) {
      console.error("Error fetching departments:", error)
    }
  }

  async onDepartmentChange(event) {
    const departmentId = event?.target?.value || event

    // Reset commune
    this.resetSelect(this.communeTarget)

    if (!departmentId) {
      return
    }

    try {
      const response = await fetch(`/api/communes?department_id=${departmentId}`)
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const communes = await response.json()

      this.populateSelect(this.communeTarget, communes)
      
      // If there was a previously selected commune, try to restore it
      if (this.communeTarget.dataset.selectedValue) {
        this.communeTarget.value = this.communeTarget.dataset.selectedValue
        delete this.communeTarget.dataset.selectedValue
      }
    } catch (error) {
      console.error("Error fetching communes:", error)
    }
  }

  populateSelect(selectElement, options) {
    if (!selectElement) return

    // Check if it's a custom select (has data-custom-select-target="input")
    const customSelectContainer = selectElement.closest('[data-controller*="custom-select"]')
    if (customSelectContainer) {
      const menu = customSelectContainer.querySelector('[data-custom-select-target="menu"]')
      const button = customSelectContainer.querySelector('[data-custom-select-target="button"]')
      
      if (menu && button) {
        const placeholder = button.dataset.placeholder || "Sélectionnez..."

        // Clear menu
        menu.innerHTML = ""

        // Add placeholder option
        const placeholderButton = document.createElement("button")
        placeholderButton.type = "button"
        placeholderButton.dataset.action = "click->custom-select#selectOption"
        placeholderButton.dataset.value = ""
        placeholderButton.className = "w-full px-4 py-3 text-left text-gray-900 hover:bg-purple-50 transition-colors"
        placeholderButton.textContent = placeholder
        menu.appendChild(placeholderButton)

        // Add options
        options.forEach((option) => {
          const optionButton = document.createElement("button")
          optionButton.type = "button"
          optionButton.dataset.action = "click->custom-select#selectOption"
          optionButton.dataset.value = option.id
          optionButton.className = "w-full px-4 py-3 text-left text-gray-900 hover:bg-purple-50 transition-colors"
          optionButton.textContent = option.name
          menu.appendChild(optionButton)
        })

        // Reset button text and value
        const buttonSpan = button.querySelector('span')
        if (buttonSpan) {
          buttonSpan.textContent = placeholder
        } else {
          // If no span, update button text directly (but preserve SVG if exists)
          const svg = button.querySelector('svg')
          button.innerHTML = `<span>${placeholder}</span>`
          if (svg) {
            button.appendChild(svg)
          }
        }
        selectElement.value = ""
        return
      }
    }

    // Fallback for native select
    const placeholder = selectElement.options[0]?.textContent || "Sélectionnez..."
    selectElement.innerHTML = ""
    const placeholderOption = document.createElement("option")
    placeholderOption.value = ""
    placeholderOption.textContent = placeholder
    selectElement.appendChild(placeholderOption)

    options.forEach((option) => {
      const optionElement = document.createElement("option")
      optionElement.value = option.id
      optionElement.textContent = option.name
      selectElement.appendChild(optionElement)
    })
  }

  resetSelect(selectElement) {
    if (!selectElement) return

    // Check if it's a custom select
    const customSelectContainer = selectElement.closest('[data-controller*="custom-select"]')
    if (customSelectContainer) {
      const menu = customSelectContainer.querySelector('[data-custom-select-target="menu"]')
      const button = customSelectContainer.querySelector('[data-custom-select-target="button"]')
      
      if (menu && button) {
        const placeholder = button.dataset.placeholder || "Sélectionnez..."

        // Clear menu and add only placeholder
        menu.innerHTML = ""
        const placeholderButton = document.createElement("button")
        placeholderButton.type = "button"
        placeholderButton.dataset.action = "click->custom-select#selectOption"
        placeholderButton.dataset.value = ""
        placeholderButton.className = "w-full px-4 py-3 text-left text-gray-900 hover:bg-purple-50 transition-colors"
        placeholderButton.textContent = placeholder
        menu.appendChild(placeholderButton)

        // Reset button text and value
        const buttonSpan = button.querySelector('span')
        if (buttonSpan) {
          buttonSpan.textContent = placeholder
        } else {
          // If no span, update button text directly (but preserve SVG if exists)
          const svg = button.querySelector('svg')
          button.innerHTML = `<span>${placeholder}</span>`
          if (svg) {
            button.appendChild(svg)
          }
        }
        selectElement.value = ""
        return
      }
    }

    // Fallback for native select
    const placeholder = selectElement.options[0]?.textContent || "Sélectionnez..."
    selectElement.innerHTML = ""
    const placeholderOption = document.createElement("option")
    placeholderOption.value = ""
    placeholderOption.textContent = placeholder
    selectElement.appendChild(placeholderOption)
    selectElement.value = ""
  }
}

