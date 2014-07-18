class EventController < ApplicationController
  def open
    if Rails.env == "production"
      open_time = DateTime.parse("2014-06-11 23:59:00 +0900")
    else
      open_time = DateTime.parse("2014-06-01 23:59:00 +0900")
    end
    result = "running"
    result = "not_yet" if Time.now < open_time
    respond_to do |format|
      format.json { render json: {result: result}, status: :ok}
    end
  end
  
  def finish
    finish_time = DateTime.parse("2014-07-20 23:59:00 +0900")
    result = "running"
    result = "finish" if Time.now > finish_time
    respond_to do |format|
      format.json { render json: {result: result}, status: :ok}
    end
  end
end
