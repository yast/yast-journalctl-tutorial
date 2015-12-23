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
require "journalctl/query_presenter.rb"

Yast.import "UI"
Yast.import "Label"
Yast.import "Popup"

module Journalctl
  # Dialog to display journal entries with several filtering options
  class EntriesDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      textdomain "journalctl"

      @query = QueryPresenter.new
      @search = ""
      read_entries
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
          Left(ReplacePoint(Id(:query), query_description)),
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
        case input = Yast::UI.UserInput
        when :cancel
          # Break the loop
          break
        when :filter
          # The user clicked the filter button
          if read_query
            read_entries
            redraw_query
            redraw_table
          end
        when :search
          # The content of the search box changed
          read_search
          redraw_table
        when :refresh
          # The user clicked the refresh button
          read_entries
          redraw_table
        else
          log.warn "Unexpected input #{input}"
        end
      end
    end

    # Table widget to display log entries
    def table
      headers = @query.columns.map {|c| c[:label] }

      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(*headers),
        table_items
      )
    end

    def table_items
      # Reduce it to an array with only the visible fields
      entries_fields = @entries.map do |entry|
        @query.columns.map {|c| entry.send(c[:method]) }
      end
      # Grep for entries matching @search in any visible field
      entries_fields.select! do |fields|
        fields.any? {|f| Regexp.new(@search, Regexp::IGNORECASE).match(f) }
      end
      # Return the result as an array of Items
      entries_fields.map {|fields| Item(*fields) }
    end

    def query_description
      Label(@query.filters_description)
    end

    def redraw_query
      Yast::UI.ReplaceWidget(Id(:query), query_description)
    end

    def redraw_table
      Yast::UI.ChangeWidget(Id(:entries_table), :Items, table_items)
    end

    # Asks the user the new query options using SystemdJournal::QueryDialog.
    #
    # @see SystemdJournal::QueryDialog
    #
    # @return [Boolean] true whether the query has changed
    def read_query
      query = QueryDialog.new(@query).run
      if query
        @query = query
        log.info "New query is #{@query}."
        true
      else
        log.info "QueryDialog returned nil. Query is still #{@query}."
        false
      end
    end

    # Gets the new search string from the interface
    def read_search
      @search = Yast::UI.QueryWidget(Id(:search), :Value)
      log.info "Search string set to '#{@search}'"
    end

    # Reads the journal entries from the system
    def read_entries
      log.info "Calling journalctl with '#{@query.journalctl_args}'"
      @entries = @query.entries
      log.info "Call to journalctl returned #{@entries.size} entries."
    rescue => e
      log.warn e.message
      @entries = []
      Yast::Popup.Message(e.message)
    end
  end
end
