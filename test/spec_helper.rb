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

# Set the paths
ENV["Y2DIR"] = File.expand_path("../../src", __FILE__)
DATA_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "data")
SRC_PATH = File.expand_path("../src", __dir__)

require "yast"

# Stub a command execution
def allow_to_execute(cmd)
  path = Yast::Path.new(".target.bash_output")
  allow(Yast::SCR).to receive(:Execute).with(path, cmd)
end

# Stubbed result from a call to journalctl using the example data
def journalctl_result
  file = File.join(DATA_PATH, "journalctl.out")
  content = File.open(file) {|f| f.read }
  {"exit" => 0, "stderr" => "", "stdout" => content}
end

# Stubbed result from a call to journalctl which went wrong
def journalctl_error(message)
  {"exit" => 1, "stderr" => message, "stdout" => ""}
end

# JSON chunk describing an entry, read from the example data directory
def json_for_entry
  file = File.join(DATA_PATH, "entry.json")
  File.open(file) {|f| f.read }
end

# configure RSpec
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    # verify that the mocked methods actually exist
    # https://relishapp.com/rspec/rspec-mocks/v/3-0/docs/verifying-doubles/partial-doubles
    c.verify_partial_doubles = true
  end
end

# enable code coverage
if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
  end

  # track all ruby files under src/lib
  SimpleCov.track_files("#{SRC_PATH}/lib/**/*.rb")
end
