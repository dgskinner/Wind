require 'net/smtp'
require 'net/http'
require 'json'

def send_email(recipient,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'email@example.com'
  opts[:from_alias]  ||= 'DuncanBot'
  opts[:subject]     ||= ''
  opts[:body]        ||= ''

  msg = <<MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{recipient}>
Subject: #{opts[:subject]}

#{opts[:body]}
MESSAGE

  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message(msg, opts[:from], recipient)
  end
end

# coordinates of Rodanthe, NC
url = 'https://api.forecast.io/forecast/e82a394c7831c1d66bcf9c0ff8812cae/35.5935,-75.4679'
uri = URI(url)

# recipients = ['6087128892@txt.att.net', '6087128842@txt.att.net', '6087129698@txt.att.net']
recipients = ['6087128892@txt.att.net']

WIND_DIRECTION_TABLE = {
	0 => 'N',
	1 => 'NNE',
	2 => 'NE',
	3 => 'ENE',
	4 => 'E',
	5 => 'ESE',
	6 => 'SE',
	7 => 'ESE',
	8 => 'S',
	9 => 'SSW',
	10 => 'SW',
	11 => 'WSW',
	12 => 'W',
	13 => 'WNW',
	14 => 'NW',
	15 => 'NNW',
	16 => 'N'
}

loop do 
	current_time = Time.now
	if (current_time.hour > 6 && current_time.hour < 20)
		response = Net::HTTP.get(uri)
		parsed_response = JSON.parse(response)
		speed = parsed_response['currently']['windSpeed'].to_s + ' mph'
		direction_key = ((parsed_response['currently']['windBearing'] + 11.25) / 22.5).floor
		direction = WIND_DIRECTION_TABLE[direction_key]
		bearing = parsed_response['currently']['windBearing'].to_s + ' degrees'
		wind_info = speed + ' ' + direction + ' (' + bearing + ') Rodanthe, NC'

		if (parsed_response['currently']['windSpeed'] > 0)

			recipients.each do |recipient|
				send_email(recipient, {subject: 'Wind Notification', body: wind_info})
			end

			puts "#{current_time.to_s[11..15]} - Notifications sent [#{wind_info}]"
			sleep(3300)
		end

		puts "#{current_time.to_s[11..15]} - Wind is below notification threshold [#{wind_info}]. Will check again in 5 minutes..."
	else 
		puts "After hours..."
	end
	sleep(300)
end
