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
require "journalctl/query_dialog.rb"

Yast.import "UI"
Yast.import "Label"

module Journalctl
  # Dialog to display journal entries with several filtering options
  class EntriesDialog

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

          # Filters
          Left(
            HBox(
              Label(_("Displaying entries with the following text")),
              HSpacing(1),
              InputField(Id(:search), Opt(:hstretch, :notify), "", "")
            )
          ),
          Left(Label(_("since system's boot with no additional conditions"))),
          VSpacing(0.3),

          # Log entries
          table,
          VSpacing(0.3),

          # Footer buttons
          HBox(
            HWeight(1, PushButton(Id(:filter), _("Change filter..."))),
            HStretch(),
            HWeight(1, PushButton(Id(:refresh), _("Refresh"))),
            HStretch(),
            HWeight(1, PushButton(Id(:cancel), Yast::Label.QuitButton))
          )
        )
      )
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    # Simple event loop
    def event_loop
      loop do
        case Yast::UI.UserInput
        when :cancel
          # Break the loop
          break
        when :filter
          if QueryDialog.new.run
            log.info "The user has set new arguments for the query"
          else
            log.info "The user canceled the query dialog"
          end
        when :search
          log.info "Handling of the search text input not implemented yet"
        when :refresh
          log.info "Handling of the refresh button not implemented yet"
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
  end
end
