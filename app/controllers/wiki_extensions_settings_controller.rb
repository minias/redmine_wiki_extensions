# Wiki Extensions plugin for Redmine
# Copyright (C) 2009-2017  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class WikiExtensionsSettingsController < ApplicationController
  unloadable
  layout 'base'

  before_action :find_project, :authorize, :find_user

  def update
    menus = params[:menus]

    setting = WikiExtensionsSetting.find_or_create @project.id
    begin
      setting.transaction do
        menus.parameters.each {|menu|
          menu_setting = WikiExtensionsMenu.find_or_create(@project.id, menu[:menu_no].to_i)
          menu_setting.assign_attributes(menu)
          menu_setting.enabled = (menu[:enabled] == 'true')
          menu_setting.save!
        }
        #setting.auto_preview_enabled = auto_preview_enabled
        setting.attributes = params.require(:setting).permit(:auto_preview_enabled, :tag_disabled)
        setting.save!
      end
      flash[:notice] = l(:notice_successful_update)
    rescue => e
      flash[:error] = "Updating failed." + e.message
    end
    
    redirect_to :controller => 'projects', :action => "settings", :id => @project, :tab => 'wiki_extensions'
  end

  private
  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:id])
  end

  def find_user
    @user = User.current
  end
end
