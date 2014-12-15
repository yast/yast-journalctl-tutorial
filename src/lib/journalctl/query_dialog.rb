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

    def initialize
      textdomain "journalctl"
    end

    # Displays the dialog
    def run
      return nil unless create_dialog

      begin
        case Yast::UI.UserInput
        when :cancel
          false
        when :ok
          true
        else
          raise "Unexpected input #{input}"
        end
      ensure
        Yast::UI.CloseDialog
      end
    end

  private

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

    # Widget allowing to select a boot option
    def boot_widget
      RadioButtonGroup(
        Id(:boot),
        VBox(
          Left(RadioButton(Id(:boot_0), _("Current boot"))),
          Left(RadioButton(Id(:boot_1), _("Previous boot")))
        )
      )
    end

    # Widget containing a checkbox per filter
    def additional_filters_widget
      filters = [
        { name: :unit, label: _("For this systemd unit") },
        { name: :file, label: _("For this file (executable or device)") },
        { name: :priority, label: _("With at least this priority") }
      ]

      checkboxes = filters.map do |filter|
        name = filter[:name]
        Left(
          HBox(
            CheckBox(Id(name), filter[:label]),
            HSpacing(1),
            MinWidth(INPUT_WIDTH, InputField(Id(:"#{name}_value"), "", ""))
          )
        )
      end

      VBox(*checkboxes)
    end
  end
end

