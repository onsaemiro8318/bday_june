class User < ActiveRecord::Base
  devise :database_authenticatable
  
  has_many :messages, dependent: :destroy
  has_many :access_logs, dependent: :destroy
  has_one :coupon, dependent: :destroy
  
  validates :agree, acceptance: true
  validates :agree2, acceptance: true
  validates :birthday, presence: true
  validates :name, presence: true
  validates :phone, presence: true
  validates :phone, uniqueness: true

  attr_accessor :birthday_month, :birthday_day

  def self.how_long
    users = User.joins(:coupon).select("users.name, users.phone, users.created_at, coupons.updated_at").where(coupons:{status:"used"})
    days = []
    workbook = WriteExcel.new('sum_user_how_long_list.xls')
    worksheet  = workbook.add_worksheet
    
    users.each_with_index do |user, i|
      how_long = (user.updated_at - user.created_at) / 60 / 60
      worksheet.write(i, 0, i+1)
      worksheet.write(i, 1 , user.name)
      worksheet.write(i, 2 , user.phone)
      worksheet.write(i, 3 , user.created_at)
      worksheet.write(i, 4 , user.updated_at)
      worksheet.write(i, 5 , how_long)
      days << how_long
    end
    workbook.close
    pp days
    days
  end
  def send_survey
    Message.send_survey_to(self)
  end
  

  def self.weekday
    User.select("sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 1 then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 2 then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 3 then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 4 then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 5 then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 6 then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 7 then 1 else 0 end) as 'sat' ")
      .where.not(phone: nil)


  end
  
  def self.write_excel
    users = self.all
    workbook = WriteExcel.new('user_list.xls')
    worksheet  = workbook.add_worksheet
    users.each_with_index do |user, i|
      worksheet.write(i, 0, i+1)
      worksheet.write(i, 1 , user.name)
      worksheet.write(i, 2 , user.phone)
    end
    
    users = self.joins(:coupon).where(coupons: {status: "used"})
    used_worksheet  = workbook.add_worksheet
    users.each_with_index do |user, i|
      used_worksheet.write(i, 0, i+1)
      used_worksheet.write(i, 1 , user.name)
      used_worksheet.write(i, 2 , user.phone)
      used_worksheet.write(i, 3 , user.coupon.status)
    end
    
    users = self.joins(:coupon).where(coupons: {status: "not_used"})
    not_used_worksheet  = workbook.add_worksheet
    users.each_with_index do |user, i|
      not_used_worksheet.write(i, 0, i+1)
      not_used_worksheet.write(i, 1 , user.name)
      not_used_worksheet.write(i, 2 , user.phone)
      not_used_worksheet.write(i, 3 , user.coupon.status)
    end
    
    workbook.close
  end
  
  def send_120_survey(phone)
    Message.send_120_survey_to(phone)
  end
    
  def self.convert_phone(phone)
    phone = phone.insert(3, "-").insert(8, "-")
  end
  
  def self.send_survey_message
    offset_start = 1
    finish = all.count
    until offset_start > finish
      all.limit(100).offset(offset_start).each do |u|
        puts u.name
        u.send_survey
      end
      offset_start = offset_start + 100
    end
  end
  
  def self.coupon_used_counts
    result = User.select("
      date(convert_tz(coupons.updated_at,'+00:00','+09:00')) used_date,
      count(*) used_count")
      .joins(:coupon)
      .where(coupons: {status: "used"})
      .group("date(convert_tz(coupons.updated_at,'+00:00','+09:00'))")
      .order("coupons.updated_at")
  end
  
  def self.coupon_used_users
    result = User.includes(:coupon)
      .where(coupons: {status: "used"})
      .order("coupons.updated_at DESC")
  end
  
  def self.count_by_device_type
    result = self.select(
      "sum(case when users.device = 'pc' then 1 else 0 end) as pc_count, 
      sum(case when users.device = 'mobile' then 1 else 0 end) as mobile_count, 
      count(*) as total_count")
  end
  
  def self.user_120
    phones = Array.new
    User.where(phone: User.coupon_users).each do |user|
      phones << user.phone
    end
    user_120 = User.coupon_users - phones
  end
  
  def self.coupon_users
    ['010-8812-5111']
  end
  
  def self.first_day()
    self.select("created_at").order("created_at").limit(1) 
  end
  
  
  def self.paginate_by_week(page)
    page ||= 1 
    page = page.to_i
    start_date = (DateTime.now-DateTime.now.wday-7*(page-1)).beginning_of_day
    end_date = (DateTime.now+(7-DateTime.now.wday)-7*(page-1)).beginning_of_day
    self.source_by_weekday(start_date,end_date)
  end
  
  def self.source_by_weekday(start_date, end_date)
    self.select("source
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 1 then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 2 then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 3 then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 4 then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 5 then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 6 then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 7 then 1 else 0 end) as 'sat' ")
        .where("created_at >= ? and created_at < ?", start_date, end_date)
        .group("source").order("source")
  end
  
  def self.paginate_by_week_sum(page)
    page ||= 1 
    page = page.to_i
    start_date = (DateTime.now-DateTime.now.wday-7*(page-1)).beginning_of_day
    end_date = (DateTime.now+(7-DateTime.now.wday)-7*(page-1)).beginning_of_day
    self.source_by_weekday_sum(start_date,end_date)
  end
  
  def self.source_by_weekday_sum(start_date,end_date)
    self.select(
      "sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 1 then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 2 then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 3 then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 4 then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 5 then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 6 then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(created_at,'+00:00','+09:00')) = 7 then 1 else 0 end) as 'sat' ")
        .where("created_at >= ? and created_at < ?", start_date, end_date)
  end
  
  def self.offset_id
    offset = 20000
    users = User.all
        # users = User.limit(5)
    users.each do |user|
      new_user = user.attributes
      new_user["id"] = new_user["id"] + offset
      user.destroy
      User.create(new_user)
    end
    access_logs = AccessLog.all
        # access_logs = AccessLog.limit(5)
    access_logs.each do |access_log|
      new_access_log = access_log.attributes
      new_access_log["id"] = new_access_log["id"] + offset
      new_access_log["user_id"] = new_access_log["user_id"] + offset
      access_log.destroy
      AccessLog.create(new_access_log)
    end
    coupons = Coupon.all
        # coupons = Coupon.limit(5)
    coupons.each do |coupon|
      new_coupon = coupon.attributes
      new_coupon["id"] = new_coupon["id"] + offset
      new_coupon["user_id"] = new_coupon["user_id"] + offset
      coupon.destroy
      Coupon.create(new_coupon)
    end
    messages = Message.all
        # messages = Message.limit(5)
    messages.each do |message|
      new_message = message.attributes
      new_message["id"] = new_message["id"] + offset
      unless new_message["user_id"].nil?
        new_message["user_id"] = new_message["user_id"] + offset
      else
        new_message["user_id"] = nil
      end
      message.destroy
      Message.create(new_message)
    end
    
  end
  
end
