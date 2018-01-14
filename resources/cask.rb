#
# Author:: Joshua Timberman (<jtimberman@chef.io>)
# Author:: Graeme Mathieson (<mathie@woss.name>)
# Cookbook:: homebrew
# Resources:: cask
#
# Copyright:: 2011-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
property :name, String, regex: /^[\w-]+$/, name_property: true # ~FC108
property :options, String

action :install do
  execute "installing cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask install #{new_resource.name} #{new_resource.options}"
    user Homebrew.owner
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    not_if { casked? }
  end
end

action :uninstall do
  execute "uninstalling cask #{new_resource.name}" do
    command "/usr/local/bin/brew cask uninstall #{new_resource.name}"
    user Homebrew.owner
    environment lazy { { 'HOME' => ::Dir.home(Homebrew.owner), 'USER' => Homebrew.owner } }
    only_if { casked? }
  end
end

action_class do
  alias_method :action_cask, :action_install
  alias_method :action_uncask, :action_uninstall

  def casked?
    shell_out('/usr/local/bin/brew cask list 2>/dev/null', user: Homebrew.owner).stdout.split.include?(name)
  end
end
