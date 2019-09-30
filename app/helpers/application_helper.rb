module ApplicationHelper
  def default_title
    key = "app.#{controller_name}.#{action_name}.title"
    output = []

    output << I18n.t(key)
    output << I18n.t('app.main.title')

    output.join(' | ')
  end

  def default_description
    I18n.t "app.#{controller_name}.#{action_name}.desc"
  end

  def flash_message
    flash.each do |type, msg|
      content_tag :div, msg, class: "alert-#{type}"
    end

    safe_join(flash.each_with_object([]) do |(type, message), messages|
      next if message.blank? || !message.respond_to?(:to_str)
      messages << content_tag( :div, message, class: "alert-#{type}")
    end, "\n").presence
  end
end
