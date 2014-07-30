class Coupon < ActiveRecord::Base
  belongs_to :user
  
  scope :used, -> { where status: 'used' }
  scope :not_used, -> { where status: 'not_used' }
  def self.weekday
    Coupon.select(
      "sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 1 and status='used' then 1 else 0 end) as 'sun'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 2 and status='used' then 1 else 0 end) as 'mon'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 3 and status='used' then 1 else 0 end) as 'tue'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 4 and status='used' then 1 else 0 end) as 'wed'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 5 and status='used' then 1 else 0 end) as 'thu'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 6 and status='used' then 1 else 0 end) as 'fri'
      ,sum(case when DayofWeek(convert_tz(coupons.updated_at,'+00:00','+09:00')) = 7 and status='used' then 1 else 0 end) as 'sat' ")
  end
  
  def self.log_file(date)
    date = date.to_s
    lines = []
    file = File.new("production02.log")
      lines = lines + file.readlines
    file.close
    file = File.new("production03.log")
      lines = lines + file.readlines
    file.close
    file = File.new("production04.log")
      lines = lines + file.readlines
    file.close
    file = File.new("production_0729.log")
      lines = lines + file.readlines
    file.close
    greps = lines.grep(/PUT.\"\/[a-z]{5}\-[0-9]{4}/)
    greps
    codes = []
    greps.each_with_index do |grep, i|
      log_time = grep.partition("INFO --").first
      updated_at = DateTime.parse(log_time).change(offset:"+0900")
      start_time = DateTime.parse "2014-07-"+date+" 00:00:00 +0900"
      finish_time = DateTime.parse "2014-07-"+date+" 23:59:59 +0900"
      if start_time < updated_at and updated_at > finish_time
        codes << {code: grep[/[a-z]{5}\-[0-9]{4}/], updated_at: updated_at}
      end
    end
    coupons = []
    codes.each do |code|
      coupon = Coupon.find_by_code(code[:code])
      unless coupon.nil?
        coupon.status = "used"
        coupon.updated_at = code[:updated_at]
        coupons << coupon.save
      end
    end
    coupons
  end
  
  
  
  # def self.log_file(day)
  #   lines = []
  #   file = File.new("production08.log")
  #     lines = lines + file.readlines
  #   file.close
  #   file = File.new("production09.log")
  #     lines = lines + file.readlines
  #   file.close
  #   file = File.new("production10.log")
  #     lines = lines + file.readlines
  #   file.close
  #   greps = lines.grep(/, "user"=>{"b/)
  #   users = []
  #   greps.each_with_index do |grep, i|
  #     hash = eval grep.partition("ters: ").last
  #     log_time = grep.partition("INFO --").first
  #     created_at = DateTime.parse(log_time).change(offset:"+0900")
  #     user = hash["user"]
  #     user["created_at"] = created_at
  #     start_time = DateTime.parse("2014-07-"+day.to_s+" 00:00:00 +0900")
  #     finish_time = DateTime.parse("2014-07-"+day.to_s+" 23:59:59 +0900")
  #     if start_time <= created_at and created_at <= finish_time
  #       u = User.create(user)
  #       coupon = Coupon.new
  #       coupon.code = coupon.random_code
  #       coupon.user = u
  #       coupon.save
  #       users << u
  #     end
  #   end
  #   users
  # end
  


  def send_message
    Message.send_to(self)
  end
  
  def send_retention
    Message.send_survey_to(self.user)
  end
  

  
  def self.send_retention_message
    offset_start = 1
    finish = not_used.count
    until offset_start > finish
      offset_start = offset_start + 100
      not_used.where("created_at < ?", DateTime.parse("2014-07-14 23:59:59 +0900")).limit(100).offset(offset_start).each do |c|
        unless c.user.nil?
          c.send_retention
        end
      end
    end
  end
  
  
  def self.send_retention_message_0718
    offset_start = 1
    finish = not_used.count
    whole = User.joins(:coupon).where(coupons:{status: "not_used"})
      .where.not(users:{phone:Coupon.exclusion_phone_numbers})
    until offset_start > finish
      offset_start = offset_start + 100
      whole.limit(100).offset(offset_start).each do |user|
        Message.send_retention_to_0718(user)
      end
    end
  end


  
  def self.send_survey_message(phones)
    i = 0
    # receivers = Coupon.joins(:user).includes(:user).where("users.phone" => User.user_120)
    # receivers = Coupon.used.joins(:user).includes(:user).where("users.phone" => User.coupon_users)
    phones.each do |phone|
      Message.send_120_survey_to(phone)
      i += 1
      puts i.to_s + "/" + phone
    end
  end
  
  
  def random_code
    alphabet = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z) * 3
    digit = %w(1 2 3 4 5 6 7 8 9 0) * 2
    code = alphabet.shuffle.join[0..4] + "-" + digit.shuffle.join[0..3]
    code
  end
  
  def is_used?
    if status == "used"
      return "used"
      
    elsif status == "not_used"
      return "not_used"

    end
  end

  def confirm
    status = "used"
    used_at = Time.now
    self.save
  end


  def self.exclusion_phone_numbers
    %w(
   )
  end
end