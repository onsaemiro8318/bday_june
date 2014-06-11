class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  def index
    @users = User.includes(:access_logs, :coupon).order("id desc").page(params[:page]).per(200)
    @user_counts = User.count_by_device_type
  end
  
  def couponused
    @coupon_used_users = User.coupon_used_users.page(params[:page]).per(200)
    @coupon_used_counts = User.coupon_used_counts
  end
  
  def logs
    id = params[:id]
    id = 1 if id.nil?
    @user_stats = User.paginate_by_week(id)
    @user_stats_sum = User.paginate_by_week_sum(id)
    @user_first_day = User.first_day()
  end
  
end
