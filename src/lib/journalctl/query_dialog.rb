# Copyright (c) 2014 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require 'yast'

Yast.import "UI"
Yast.import "Label"

module Journalctl
  # Dialog allowing the user to set the arguments used to display the journal
  # entries in Journalctl::EntriesDialog
  #
  # @see Journalctl::EntriesDialog
  class QueryDialog

    include Yast::UIShortcuts
    include Yast::I18n

    INPUT_WIDTH = 20

    def initialize(query)
      textdomain "journalctl"
      @query = query
    end

    # Displays the dialog
    def run
      return nil unless create_dialog

      begin
        case input = Yast::UI.UserInput
        when :cancel
          nil
        when :ok
          query_from_widgets
        else
          raise "Unexpected input #{input}"
        end
      ensure
        Yast::UI.CloseDialog
      end
    end

  private

    # Translates the value of the widgets to a new QueryPresenter object
    def query_from_widgets
      boot = Yast::UI.QueryWidget(Id(:boot), :CurrentButton)
      filters = { boot: boot }

      QueryPresenter.additional_filters.each do |filter|
        name = filter[:name]
        # If the checkbox is checked
        if Yast::UI.QueryWidget(Id(name), :Value)
          # Read the widget...
          value = Yast::UI.QueryWidget(Id(:"#{name}_value"), :Value)
          # ...discarding empty values
          filters[name] = value unless value.empty?
        end
      end

      QueryPresenter.new(filters)
    end

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        VBox(
          # Header
          Heading(_("Entries to display")),

          # Boot selector
          Frame(
            _("Log entries for"),
            boot_widget
          ),
          VSpacing(0.3),

          # Filter checkboxes
          Frame(
            _("Filters"),
            additional_filters_widget
          ),
          VSpacing(0.3),

          # Footer buttons
          HBox(
            PushButton(Id(:cancel), Yast::Label.CancelButton),
            PushButton(Id(:ok), Yast::Label.OKButton)
          )
        )
      )
    end

    def boot_widget
      RadioButtonGroup(Id(:boot), VBox(*boot_buttons))
    end

    # Array of radio buttons to select the boot
    def boot_buttons
      QueryPresenter.boot_options.map do |opt|
        value = opt[:value]
        selected = value === @query.filters[:boot]

        Left(RadioButton(Id(value), opt[:label], selected))
      end
    end

    # Widget allowing to set the filters
    def additional_filters_widget
      filters = QueryPresenter.additional_filters.map do |filter|
        name = filter[:name]
        Left(
          HBox(
            CheckBox(Id(name), filter[:label], !@query.filters[name].nil?),
            HSpacing(1),
            widget_for_filter(name, filter[:values])
          )
        )
      end
      VBox(*filters)
    end

    # Widget to set the value of a given filter.
    #
    # If the second argument is nil, an input field will be used. Otherwise, a
    # combo box will be returned.
    #
    # @param name [Symbol] name of the filter
    # @param values [Array] optional list of values for the combo box
    def widget_for_filter(name, values = nil)
      id = Id(:"#{name}_value")
      if values
        items = values.map do |value|
          Item(Id(value), value, @query.filters[name] == value)
        end
        ComboBox(id, "", items)
      else
        MinWidth(INPUT_WIDTH, InputField(id, "", @query.filters[name] || ""))
      end
    end
  end
end

