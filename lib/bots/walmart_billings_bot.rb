# frozen_string_literal: true
class WalmartBillingsBot < WalmartBot
  def notification
    {
      title: "Found appointment at Walmart South Keys",
      message: "Walmart at 2210 Bank St. has an appointment. https://portal.healthmyself.net/walmarton/forms/Dpd",
    }
  end

  def build_response
    WalmartBot::Response.new(
      location_id: 1180,
      hm_session_cookie: Global.config.walmart_bot.cookie
    )
  end
end
