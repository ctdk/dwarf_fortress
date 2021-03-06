# This file minimally adapted from pivotal_workstation's librariers/user.rb

# The MIT License

# Copyright (c) 2009-2010 Matthew Kocher, Steve Conover and Pivotal Labs

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

fail 'sudo to root before running' if ENV['SUDO_USER'].nil?

DF_USER = ENV['SUDO_USER'].strip
DF_HOME = (ENV['HOME'] != '/root') ? ENV['HOME'] : `getent passwd $SUDO_USER | cut -d: -f6`.strip
DF_LIBRARY = "#{DF_HOME}/Library"

fail 'should not be root' if DF_USER == 'root'
