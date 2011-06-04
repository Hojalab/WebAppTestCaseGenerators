# Web application test path generators
# Copyright (C) 2011 Sarah Vessels <cheshire137@gmail.com>
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'test/unit'

class Test::Unit::TestCase
  BasePath = File.expand_path(File.dirname(__FILE__)).freeze

  # Returns contents of ERB file with the given prefix
  def fixture(file_name_prefix)
	path = File.join(BasePath, 'fixtures', sprintf("%s.erb", file_name_prefix))
	IO.readlines(path).join
  end
end
