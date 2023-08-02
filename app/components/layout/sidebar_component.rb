# frozen_string_literal: true

module Layout
  # Sidebar component to for navigation
  class SidebarComponent < Component
    attr_reader :label, :icon_name

    renders_one :header, Sidebar::HeaderComponent
    renders_many :sections, Sidebar::SectionComponent
    renders_many :items, Sidebar::ItemComponent

    def initialize(label:, icon_name:, **system_arguments)
      @label = label.length > 14 ? "#{label[0..14]}..." : label
      @icon_name = icon_name
      @system_arguments = system_arguments
    end
  end
end
