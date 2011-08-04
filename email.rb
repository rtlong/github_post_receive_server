class Email
  def initialize(opts={})
    opts[:server]      ||= 'home.rtlong.com'
    opts[:from]        ||= 'updates@github.home.rtlong.com'
    opts[:from_alias]  ||= 'Github Push Notifier'
    opts[:subject]     ||= "Github Post Receive Report"

    @opts = opts
  end

  def send(to,opts={})
    opts.merge!(@opts)
    
    raise ArgumentError unless opts[:body]

    msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    Net::SMTP.start(opts[:server]) do |smtp|
      smtp.send_message msg, opts[:from], to
    end
  end
end
 
