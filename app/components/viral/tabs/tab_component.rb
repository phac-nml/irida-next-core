# frozen_string_literal: true

module Viral
  module Tabs
    class TabComponent < Viral::Component
      erb_template <<-ERB
        <%= link_to @url, class: @link_classes, role: "tab", data: { turbo_frame: "_top" }, aria: { controls: "DFS", selected: @selected } do %>
          <%= content %>
        <% end %>
      ERB

      def initialize(url:, selected: false)
        @url = url
        @selected = selected
        @link_classes = class_names(
          {
            'inline-block p-4 text-primary-600 border-b-2 border-primary-600 rounded-t-lg active dark:text-primary-500 dark:border-primary-500': selected,
            'inline-block p-4 border-b-2 border-transparent rounded-t-lg hover:text-slate-600 hover:border-slate-300 dark:hover:text-slate-300': !selected
          }
        )
      end
    end
  end
end
