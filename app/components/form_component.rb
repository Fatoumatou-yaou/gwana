class FormComponent < ViewComponent::Base
  def initialize(
    title: nil,
    subtitle: nil,
    submit_label: "Enregistrer",
    cancel_path: nil,
    cancel_label: "Annuler",
    form_object: nil
  )
    @title = title
    @subtitle = subtitle
    @submit_label = submit_label
    @cancel_path = cancel_path
    @cancel_label = cancel_label
    @form_object = form_object
  end

  private

  attr_reader :title, :subtitle, :submit_label, :cancel_path, :cancel_label, :form_object

  def has_errors?
    form_object&.errors&.any?
  end

  def errors
    form_object&.errors || []
  end
end
