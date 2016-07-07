#
# Cookbook Name:: ipset
# Recipe:: default
#
# Copyright (C) 2015 Brad Ison
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Default to embedded omnibus ruby for the rebuild-ipset script, but
# use the system ruby if one is installed.
hashbang = '/opt/chef/embedded/bin/ruby'
hashbang = '/usr/bin/ruby' if ::File.exist?('/usr/bin/ruby')

package 'ipset'

execute 'rebuild-ipset' do
  command '/usr/sbin/rebuild-ipset'
  action :nothing
end

%w( /etc/ipset /etc/ipset/sets.d ).each do |d|
  directory d
end

template '/usr/sbin/rebuild-ipset' do
  source 'rebuild-ipset.erb'
  mode '0755'
  variables(
    hashbang: hashbang,
    os_plat: node['platform_family']
  )
end

if node['platform_family'] == 'debian'
  template '/etc/network/if-pre-up.d/00-ipset_load' do
    source 'ipset_load.erb'
    mode '0755'
    variables(
      ipset_save_file: '/etc/ipset/ipset-generated',
      os_plat: node['platform_family']
    )
  end
end

if node['platform_family'] == 'rhel'
  template '/sbin/ifup-local' do
    source 'ipset_load.erb'
    mode '0755'
    variables(
      ipset_save_file: '/etc/ipset/ipset-generated',
      os_plat: node['platform_family']
    )
  end 
end
