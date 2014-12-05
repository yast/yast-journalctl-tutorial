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

module Journalctl
  class MockupDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def run

      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        Label(_("Hello world!"))
      )

      input = Yast::UI.UserInput

      log.info "Received #{input}"

      Yast::UI.CloseDialog
    end
  end
end
