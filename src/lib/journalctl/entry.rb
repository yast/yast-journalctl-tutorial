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

require "json"
require "yast"

module Journalctl
  # An entry in the systemd journal
  class Entry

    attr_reader :raw, :timestamp, :pid, :process_name, :syslog_id,
      :unit, :message

    JOURNALCTL = "LANG=C journalctl --no-pager -o json"

    def initialize(json)
      @raw = JSON.parse(json)
      @pid = @raw["_PID"]
      @process_name = @raw["_COMM"]
      @syslog_id = @raw["SYSLOG_IDENTIFIER"]
      @unit = @raw["_SYSTEMD_UNIT"]
      @message = @raw["MESSAGE"]
      @timestamp = Time.at(@raw["__REALTIME_TIMESTAMP"].to_f/1000000)
    end

    # Calls journalctl and returns an array of Entry objects
    #
    # @param journalctl_args [String] Additional arguments to journalctl
    def self.all(journalctl_args = "")
      output = journalctl_output(journalctl_args)
      # Ignore lines not representing journal entries, like the following
      # -- Reboot --
      json_entries = output.each_line.select do |line|
        line.start_with?("{")
      end

      json_entries.map do |json|
        new(json)
      end
    end

  private

    # Handles the journalctl call
    #
    # @param args [String] arguments to journalctl
    # @return [String] command output
    def self.journalctl_output(args)
      cmd = "#{JOURNALCTL} #{args}".strip
      path = Yast::Path.new(".target.bash_output")
      cmd_result = Yast::SCR.Execute(path, cmd)

      if cmd_result["exit"].zero?
        cmd_result["stdout"]
      else
        if cmd_result["stderr"] =~ /^Failed to .* timestamp:/
          # Most likely, journalctl bug when an empty list is found
          ""
        else
          raise "Calling journalctl failed: #{cmd_result["stderr"]}"
        end
      end
    end
  end
end
