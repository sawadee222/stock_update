module Utils::CommonUtil

  def self.send_mail(config_key = "s_system", subject = "", body = "", attached_files = Array.new())
    # メールの設定
    mail_config = EasySettings.mail[config_key]
    
    sm = SendMail.new(option)

    header = @@mail_config[config_key][:header]
    header[:subject] = subject
    sm.set_header(header)
    sm.set_text_part(body)
    attached_files.each do |attached_file|
      sm.set_file(attached_file)
    end
    # メール送信
    msg = sm.deliver()
    if msg == "" then
      Rails.logger.info("Mail Send Success")
    else
      Rails.logger.error("Mail Send Failed(" + msg.to_s + ")")
    end
  end
  
end