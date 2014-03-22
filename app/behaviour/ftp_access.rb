module FtpAccess

  require 'net/ftp'

  def demos
    @demos ||= ftp.nlst("#{tf_dir}/*.dem")
  end

  def logs
    @logs ||= ftp.nlst("#{tf_dir}/logs/*.log")
  end

  def copy_to_server(files, destination)
    ftp_action(:putbinaryfile, files, destination)
  end

  def copy_from_server(files, destination)
    logger.info "FTP GET, FILES: #{files} DESTINATION: #{destination}"
    files.each do |file|
      ftp.getbinaryfile(file, File.join(destination, File.basename(file)))
    end
  end

  def delete_from_server(files)
    files.each do |file|
      begin
        ftp.send(:delete, file.shellescape)
      rescue Net::FTPPermError
        Rails.logger.error "couldn't delete file: #{file.shellescape}"
      end
    end
  end

  def ftp_action(action, files, destination)
    logger.info "FTP #{action}, FILES: #{files} DESTINATION: #{destination}"
    files.each do |file|
       ftp.send(action, file.to_s, destination)
    end
  end

  def zip_file_creator_class
    FtpZipFileCreator
  end

  def ftp
    @ftp ||= begin
               ftp = Net::FTP.new(ip, ftp_username, ftp_password)
               ftp.passive = true
               ftp
             end
  end
end