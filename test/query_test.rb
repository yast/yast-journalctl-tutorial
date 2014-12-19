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

require_relative "spec_helper"
require "journalctl/query"

describe Journalctl::Query do

  describe "#journalctl_args" do
    subject { Journalctl::Query.new(filters).journalctl_args }

    context "when no filters are provided" do
      let(:filters) { {} }

      it "generates an empty string" do
        expect(subject).to eq("")
      end
    end

    context "when :boot is an empty string" do
      let(:filters) { { boot: "" } }

      it "generates an empty --boot" do
        expect(subject).to eq("--boot=\"\"")
      end
    end

    context "when :boot is a string" do
      let(:filters) { { boot: "0dc+1" } }

      it "passes the value to --boot" do
        expect(subject).to eq("--boot=\"0dc+1\"")
      end
    end

    context "when :boot is a number" do
      let(:filters) { { boot: -1 } }

      it "passes the value to --boot" do
        expect(subject).to eq("--boot=\"-1\"")
      end
    end

    context "when an invalid filter is used" do
      let(:filters) { { whatever: "you need" } }

      it "ignores the invalid filters" do
        expect(subject).to eq("")
      end
    end

    context "when several filters are used" do
      let(:filters) {
        {
          boot: -1,
          unit: "sshd.service",
          match: "/dev/sda",
          priority: 3
        }
      }

      it "combines them all" do
        expect(subject).
          to eq("--boot=\"-1\" --priority=\"3\" --unit=\"sshd.service\" \"/dev/sda\"")
      end
    end
  end
end
