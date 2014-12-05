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

require "yast"

Yast.import "UI"
Yast.import "Label"

module Journalctl
  # Dialog to display journal entries with several filtering options
  class MockupDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      textdomain "journalctl"
    end
     
    # Displays the dialog
    def run
      return unless create_dialog

      begin
        return event_loop
      ensure
        close_dialog
      end
    end

  private

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # Header
          Heading(_("Journal entries")),

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

          # Refresh
          Right(PushButton(Id(:refresh), _("Refresh"))),
          VSpacing(0.3),

          # Log entries
          table,
          VSpacing(0.3),

          # Quit button
          PushButton(Id(:cancel), Yast::Label.QuitButton)
        )
      )
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    # Simple event loop 
    def event_loop
      loop do
        input = Yast::UI.UserInput
        if input == :cancel
          # Break the loop
          break
        else
          log.warn "Unexpected input #{input}"
        end
      end
    end

    # Table widget to display log entries
    def table
      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(
          _("Time"),
          _("Source"),
          _("Message"),
        ),
        []
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
            InputField(Id(:"#{name}_value"), "", "")
          )
        )
      end

      VBox(*checkboxes)
    end
  end
end
