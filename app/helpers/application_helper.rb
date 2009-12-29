# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def repo_view_path repository
    "/docs/#{repository.document.name}.#{repository.name}"
  end

  def radio_can_changed_by default='all'
    ret = radio_button_tag('can_changed_by', 'all', default == 'all')
    ret << "F&uuml;r alle Benutzer schreibbar"
    ret << radio_button_tag('can_changed_by', 'owner', default == 'owner')
    ret << "Nur f&uuml;r mich schreibbar"
  end
end
