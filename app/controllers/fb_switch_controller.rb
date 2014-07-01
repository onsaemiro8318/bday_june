class FbSwitchController < ApplicationController
  def index
    if request.referer.nil?
      referer = "-"
    else
      referer = URI(request.referer || '').scheme + "://" + URI(request.referer || '').host 
    end
    session[:referer] = request.referer
    tracking_id = Rails.application.secrets.ga_tracking_id
    url = Rails.application.secrets.url 
    user_agent = UserAgent.parse(request.user_agent)
    source = params[:s] || "-"
    if user_agent.mobile?
      redirect_to mobile_index_path({s: params[:s]})
    else
      device = "pc"
      s = params[:s] || ""
      @traffic_log = TrafficLog.new
      @traffic_log.ip = request.remote_ip 
      @traffic_log.device = device
      @traffic_log.referer = referer
      @traffic_log.source = source
      @traffic_log.save
      session[:source] = source
      redirect_to Rails.application.secrets.page_tab_address
    end
  end
end
