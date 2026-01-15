class MultiStepFormComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(
    form_builder:,
    model:,
    regions:,
    departments: [],
    communes: [],
    show_identity_document: false,
    submit_label: "Envoyer",
    cancel_path: nil,
    cancel_label: "Annuler"
  )
    @form_builder = form_builder
    @model = model
    @regions = regions
    @departments = departments
    @communes = communes
    @show_identity_document = show_identity_document
    @submit_label = submit_label
    @cancel_path = cancel_path
    @cancel_label = cancel_label
  end

  private

  attr_reader :form_builder, :model, :regions, :departments, :communes, 
              :show_identity_document, :submit_label, :cancel_path, :cancel_label

  def f
    form_builder
  end

  def has_errors?
    model&.errors&.any? || (model.is_a?(Gwana) && model.user&.errors&.any?)
  end

  def errors
    model&.errors || []
  end

  def step_titles
    [
      "Informations personnelles",
      "Localisation",
      "Profil professionnel",
      show_identity_document ? "Réseaux sociaux et documents" : "Réseaux sociaux et photo"
    ]
  end

  def is_gwana_with_user?
    model.is_a?(Gwana) && model.user.present?
  end
end

