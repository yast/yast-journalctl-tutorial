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

#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "journalctl/query"
require "journalctl/entry_presenter"
require "delegate"

module Journalctl
  # Presenter for Query adding useful methods for the dialogs
  class QueryPresenter < SimpleDelegator

    include Yast::I18n
    extend Yast::I18n
    # To be used in class methods
    textdomain "journalctl"

    def initialize(args = {})
      # To be used in instance methods
      textdomain "journalctl"

      # Provides a default value for :boot
      # and ensures that it's always present and not nil
      query_args = args.dup
      query_args[:boot] = "0" unless args[:boot]

      query = Query.new(query_args)
      __setobj__(query)
    end

    # Original query
    def query
      __getobj__
    end

    # Decorated entries
    #
    # @return [Array<EntryPresenter]
    def entries
      query.entries.map {|entry| EntryPresenter.new(entry) }
    end

    # User readable description of the current filters
    def filters_description
      if filters[:boot].to_s == "-1"
        desc_boot = _("from previous boot")
      else
        desc_boot = _("since system's boot")
      end

      strings = [
        [:unit, _("unit (%s)")],
        [:match, _("file (%s)")],
        [:priority, _("priority (%s)")]
      ]
      others = []

      strings.each do |filter, string|
        if value = filters[filter]
          others << string % value
        end
      end

      if others.empty?
        desc_others = _("with no additional conditions")
      else
        desc_others = _("filtering by %s") % others.join(", ")
      end

      "#{desc_boot} #{desc_others}"
    end

    # Possible options for the :boot filter to be used in forms
    #
    # @return [Array<Hash>] each option is represented by a hash with two keys
    #                 :value and :label
    def self.boot_options
      [
        {value: "0", label: _("Since system's boot")},
        {value: "-1", label: _("From previous boot")}
      ]
    end

    # Possible filters (in addition to :boot) to be used in forms
    #
    # @return [Array<Hash>] for each filter there are 3 possible keys
    #   * :name name of the filter
    #   * :label label for the widget used to set the filter
    #   * :values optional list of valid values
    def self.additional_filters
      [
        {
          name: :unit,
          label: _("For this systemd unit"),
        },
        {
          name: :match,
          label: _("For this file (executable or device)"),
        },
        {
          name: :priority,
          label: _("With at least this priority"),
          values: ["emerg", "alert", "crit", "err", "warning",
                   "notice", "info", "debug"]
        }
      ]
    end

    # Fields to display for listing the entries
    #
    # @return [Array<Hash>] for each column a :label and a :method is provided
    def columns
      [
        {label: _("Time"), method: :formatted_time},
        {label: _("Source"), method: :source},
        {label: _("Message"), method: :message}
      ]
    end
  end
end
