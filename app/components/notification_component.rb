class NotificationComponent < ViewComponent::Base
    def initialize(type: :notice, message: nil)
      @type = type
      @message = message
    end
  
    private
  
    def container_classes
      base_classes = "fixed top-4 right-4 z-100 transition-all duration-300 transform"
      case @type
      when :notice, :success
        "#{base_classes} bg-green-50 text-green-700"
      when :alert, :error
        "#{base_classes} bg-red-50 text-red-700"
      when :warning
        "#{base_classes} bg-yellow-50 text-yellow-700"
      when :info
        "#{base_classes} bg-blue-50 text-blue-700"
      end
    end
  
    def icon
      case @type
      when :notice, :success
        "check_circle"
      when :alert, :error
        "error"
      when :warning
        "warning"
      when :info
        "info"
      end
    end
  end

