
require 'net/smtp'

class Email
  def initialize(opts={})
    @server     = opts[:server]     || 'home.rtlong.com'
    @from       = opts[:from]       || 'postbox@rtlong.com'
    @from_alias = opts[:from_alias] || 'Git Push Notifier'
    @body       = opts[:body]
    @subject    = opts[:subject]
  end
  attr_accessor :server, :from, :from_alias, :body, :subject

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

    Net::SMTP.start(@server) do |smtp|
      smtp.send_message msg, @from, to
      puts "Sent mail (#{@subject || "{blank subject}"}) to #{to}" 
    end
  end
end
 
