# encoding: ascii-8bit

# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

ignore /~$/
ignore /^(?:.*[\\\/])?\.[^\\\/]+\.sw[p-z]$/

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bundle exec rspec --color' do
  watch('spec/spec_helper.rb')    { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/cosmos/(.+)\.rb$}) { |m| "spec/#{m[1]}/#{m[1]}_spec.rb" }
  watch(%r{^lib/cosmos/(.+)/(.+)\.rb$}) { |m| "spec/#{m[1]}/#{m[2]}_spec.rb" }
end
