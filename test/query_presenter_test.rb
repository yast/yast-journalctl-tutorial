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
require "journalctl/query_presenter"

describe Journalctl::QueryPresenter do
  let(:presenter) { Journalctl::QueryPresenter.new }

  describe "#entries" do
    let(:query) { presenter.query }
    subject { presenter.entries }

    before do
      allow(query).to receive(:entries).
        and_return([Journalctl::Entry.new(json_for_entry)])
    end

    it "returns an array of EntryPresenter objects" do
      expect(subject.map(&:class)).to eq([Journalctl::EntryPresenter])
    end

    it "delegates the fetching to its query" do
      expect(subject.first.raw).to eq(query.entries.first.raw)
    end
  end

  describe "#initialize" do
    it "ensures the presence of :boot" do
      expect(presenter.filters.keys).to include(:boot)
    end
  end
end
