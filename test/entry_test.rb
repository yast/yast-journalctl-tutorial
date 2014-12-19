#! rspec
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

require "time"
require_relative "spec_helper"
require "journalctl/entry"

describe Journalctl::Entry do

  describe ".all" do
    subject { Journalctl::Entry.all }
    # Stub journalctl call
    before do
      allow_to_execute(/LANG=C journalctl/).and_return(result)
    end

    context "when journalctl reports 'Failed to determine timestamp'" do
      let(:result) {
        journalctl_error("Failed to determine timestamp: Cannot assign")
      }

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when journalctl reports 'Failed to get realtime timestamp'" do
      let(:result) {
        journalctl_error("Failed to get realtime timestamp: Cannot assign")
      }

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when journalctl reports an unexpected error" do
      let(:result) {
        journalctl_error("There are always more ways to crash")
      }

      it "raises RuntimeError" do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context "when journalctl works" do
      let(:result) { journalctl_result }

      it "ignores journalctl markers" do
        expect(subject.size).to eq(7)
      end

      it "returns an array of Entry objects" do
        expect(subject.all? {|e| e.is_a?(Journalctl::Entry)}).to eq(true)
      end

      it "honours the entries order" do
        names = [ "nfs", "wickedd-dhcp4", "wickedd-dhcp6", nil,
                  "systemd-journal", "systemd-journal", nil ]
        expect(subject.map(&:process_name)).to eq(names)
      end
    end
  end

  describe "#initialize" do
    subject { Journalctl::Entry.new(json_for_entry) }

    it "stores the process name as a string" do
      expect(subject.process_name).to eq("nfs")
    end

    it "stores the timestamp as a Time object" do
      entry_time = Time.parse("2014-11-24 08:07:01 +0100")
      expect(subject.timestamp).to be_a(Time)
      expect(subject.timestamp.to_i).to eq(entry_time.to_i)
    end
  end
end
