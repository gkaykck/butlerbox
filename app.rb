require 'net/imap'
require 'yaml'

class MailChecker

  def initialize
    @configuration = Yaml.load('config.yml')

    File.delete('mail_checker.log')

    while true do
      begin
        check_mails
      rescue StandardError =>e
        File.open('mail_checker.log', 'a+') { |file| file.write(e.message) }
      end

    end
  end

  def update_configuration
    @configuration = Yaml.load('config.yml')
  end

  def check_mails
    update_configuration

    begin
      @imap = Net::IMAP.new(@email.auth_credential.credentials['in']['configuration']['address'], @email.auth_credential.credentials['in']['configuration']['port'], true, nil, false)
    rescue
      @imap = Net::IMAP.new(@email.auth_credential.credentials['in']['configuration']['address'], @email.auth_credential.credentials['in']['configuration']['port'], false, nil, false)
    end

    @imap.select('INBOX')
    new_flag_status = @imap.searct('NOT','SEEN').count > 0 ? true : false
    @flag_status =

    if new_flag_status != @flag_status
      @flag_status = new_flag_status
      if @flag_status
        raise_flag
      else
        lower_flag
      end

    end


    sleep(@configuration.interval)
  end

  def raise_flag
    # We could use the hardware GPIO in future releases.
    @pwm = RPi::GPIO::PWM.new(@configuration.pwm_pin, @configuration.pwm_up)
  end

  def lower_flag
    @pwm.frequency = @configuration.pwm_down
    @pwm.stop
  end

end

mailChecker = MailChecker.new
