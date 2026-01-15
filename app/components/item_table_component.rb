class ItemTableComponent < ViewComponent::Base
  include Pagy::Frontend

  def initialize(
    items:,
    columns:,
    item_type:,
    scope: [],
    actions: [],
    display_new_button: false,
    empty_message: "Aucun élément trouvé pour l'instant.",
    pagy: nil
  )
    @items = items
    @columns = columns
    @item_type = item_type
    @scope = scope
    @actions = actions
    @display_new_button = display_new_button
    @empty_message = empty_message
    @pagy = pagy
    @route_base = @scope.present? ? "#{@scope.join('_')}_#{@item_type}" : @item_type
  end

  def new_link
    case @item_type.to_s
    when "gwana"
      @scope.include?("admin") ? :new_admin_gwana_path : :new_gwana_path
    when "article"
      @scope.include?("admin") ? :new_admin_article_path : :new_article_path
    when "user"
      @scope.include?("admin") ? :new_admin_user_path : :new_user_path
    when "gwana_update_request"
      @scope.include?("admin") ? :new_admin_gwana_update_request_path : :new_gwana_update_request_path
    when "gwana_network_request"
      @scope.include?("admin") ? :new_admin_gwana_network_request_path : :new_gwana_network_request_path
    else
      "new_#{@route_base}_path".to_sym
    end
  end

  def show_link
    case @item_type.to_s
    when "gwana"
      @scope.include?("admin") ? :admin_gwana_path : :gwana_path
    when "article"
      @scope.include?("admin") ? :admin_article_path : :article_path
    when "user"
      @scope.include?("admin") ? :admin_user_path : :user_path
    when "gwana_update_request"
      @scope.include?("admin") ? :admin_gwana_update_request_path : :gwana_update_request_path
    when "gwana_network_request"
      @scope.include?("admin") ? :admin_gwana_network_request_path : :gwana_network_request_path
    else
      "#{@route_base}_path".to_sym
    end
  end

  def edit_link
    case @item_type.to_s
    when "gwana"
      @scope.include?("admin") ? :edit_admin_gwana_path : :edit_gwana_path
    when "article"
      @scope.include?("admin") ? :edit_admin_article_path : :edit_article_path
    when "user"
      @scope.include?("admin") ? :edit_admin_user_path : :edit_user_path
    when "gwana_update_request"
      @scope.include?("admin") ? :edit_admin_gwana_update_request_path : :edit_gwana_update_request_path
    when "gwana_network_request"
      @scope.include?("admin") ? :edit_admin_gwana_network_request_path : :edit_gwana_network_request_path
    else
      "edit_#{@route_base}_path".to_sym
    end
  end

  def delete_link
    case @item_type.to_s
    when "gwana"
      @scope.include?("admin") ? :admin_gwana_path : :gwana_path
    when "article"
      @scope.include?("admin") ? :admin_article_path : :article_path
    when "user"
      @scope.include?("admin") ? :admin_user_path : :user_path
    when "gwana_update_request"
      @scope.include?("admin") ? :admin_gwana_update_request_path : :gwana_update_request_path
    when "gwana_network_request"
      @scope.include?("admin") ? :admin_gwana_network_request_path : :gwana_network_request_path
    else
      "#{@route_base}_path".to_sym
    end
  end

  def decorate_item(item)
    case @item_type.to_s
    when "gwana"
      GwanaDecorator.new(item)
    when "article"
      item # Article n'a pas besoin de decorator pour l'instant
    when "user"
      item # User n'a pas besoin de decorator pour l'instant
    when "gwana_update_request"
      item # GwanaUpdateRequest n'a pas besoin de decorator pour l'instant
    when "gwana_network_request"
      item # GwanaNetworkRequest n'a pas besoin de decorator pour l'instant
    else
      item
    end
  end

  def route_params(item)
    params = {}

    # Pour les gwanas admin, on n'a pas besoin de paramètres de scope supplémentaires
    if @item_type.to_s == "gwana" && @scope.include?("admin")
      params[:id] = item.id
      return params
    end

    # Pour les articles admin, on n'a pas besoin de paramètres de scope supplémentaires
    if @item_type.to_s == "article" && @scope.include?("admin")
      params[:id] = item.id
      return params
    end

    # Pour les users admin, on n'a pas besoin de paramètres de scope supplémentaires
    if @item_type.to_s == "user" && @scope.include?("admin")
      params[:id] = item.id
      return params
    end

    # Pour les gwana_update_requests admin, on n'a pas besoin de paramètres de scope supplémentaires
    if @item_type.to_s == "gwana_update_request" && @scope.include?("admin")
      params[:id] = item.id
      return params
    end

    # Pour les gwana_network_requests admin, on n'a pas besoin de paramètres de scope supplémentaires
    if @item_type.to_s == "gwana_network_request" && @scope.include?("admin")
      params[:id] = item.id
      return params
    end

    @scope.each do |s|
      params["#{s}_id".to_sym] = item.send("#{s}_id")
    end

    params[:id] = item.id
    params
  end

  private

  attr_reader :items, :columns, :item_type, :scope, :actions, :display_new_button,
              :empty_message, :route_base, :pagy

  def can_perform_action?(item, action)
    policy_target = scope.include?("admin") ? [:admin, item] : item
    helpers.policy(policy_target).send("#{action == 'delete' ? 'destroy' : action}?")
  end
end
