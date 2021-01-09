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

class RunningScriptController < ApplicationController

  def index
    render :json => RunningScript.all
  end

  def show
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      render :json => running_script
    else
      head :not_found
    end
  end

  def stop
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", "stop")
      head :ok
    else
      head :not_found
    end
  end

  def pause
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", "pause")
      head :ok
    else
      head :not_found
    end
  end

  def retry
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", "retry")
      head :ok
    else
      head :not_found
    end
  end

  def go
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", "go")
      head :ok
    else
      head :not_found
    end
  end

  def step
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", "step")
      head :ok
    else
      head :not_found
    end
  end

  def prompt
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      if params[:password]
        # TODO: ActionCable is logging this ... probably shouldn't
        ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", { method: params[:method], password: params[:password] })
      else
        ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", { method: params[:method], result: params[:answer] })
      end
      head :ok
    else
      head :not_found
    end
  end

  def method
    running_script = RunningScript.find(params[:id].to_i)
    if running_script
      ActionCable.server.broadcast("cmd-running-script-channel:#{params[:id]}", { method: params[:method], args: params[:args] })
      head :ok
    else
      head :not_found
    end
  end
end
