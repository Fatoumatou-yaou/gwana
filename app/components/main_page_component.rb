class MainPageComponent < ViewComponent::Base
  def initialize(title:, class_name: "text-left")
    @title = title
    @class_name = class_name
  end

  private

  attr_reader :title, :class_name
end
