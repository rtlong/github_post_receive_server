
require 'net/smtp'

class Email
  def initialize(opts={})
    @from       = opts[:from]       || 'github@rtlong.com'
    @from_alias = opts[:from_alias] || 'Git Push Notifier'
    @body       = opts[:body]
    @subject    = opts[:subject]
  end
  attr_accessor :from, :from_alias, :body, :subject

  def send(to,opts={})
    instance_variables.each do |var|
      option_name = var[1..-1].to_sym
      opt = opts.delete(option_name)
      instance_variable_set( var, opt ) if opt
    end
    $stderr.puts "Email#send was called with the following unimplemented options:\n #{opts.inspect}" unless opts.empty?

    raise ArgumentError, "You need to specify the :body option." unless @body

    msg = <<END_OF_MESSAGE
From: #{@from_alias} <#{@from}>
To: <#{to}>
Subject: #{@subject}

#{@body}
END_OF_MESSAGE

    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start(ENV['GOOGLE_MAIL_DOMAIN'], ENV['GOOGLE_MAIL_LOGIN'].strip, ENV['GOOGLE_MAIL_PASSWORD'].strip, :login) do
      smtp.send_message msg, @from, to
    end
    puts "Sent mail (#{@subject || "{blank subject}"}) to #{to}"
  end
end

