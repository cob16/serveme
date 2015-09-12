class SshServer < RemoteServer

  def find_process_id
    execute("ps ux | grep port | grep #{port} | grep srcds_linux | grep -v grep | grep -v ruby | awk '{print \$2}'")
  end

  def demos
    @demos ||= shell_output_to_array(execute("ls #{tf_dir}/*.dem"))
  end

  def logs
    @logs ||= shell_output_to_array(execute("ls #{tf_dir}/logs/*.log"))
  end

  def list_files(dir)
    files = []
    Net::SFTP.start(ip, nil) do |sftp|
      sftp.dir.foreach(File.join(tf_dir, dir)) do |entry|
        files << entry.name
      end
    end
    files
  end

  def delete_from_server(files)
    execute("rm -f #{files.map(&:shellescape).join(' ')}")
  end

  def restart
    if process_id
      logger.info "Killing process id #{process_id}"
      kill_process
    else
      logger.error "No process_id found for server #{id} - #{name}"
    end
  end

  def execute(command)
    logger.info "executing remotely: #{command}"
    ssh_exec(command).stdout
  end

  def ssh_exec(command)
    ssh.ssh(ip, command)
  end

  def copy_to_server(files, destination)
    logger.info "SCP PUT, FILES: #{files} DESTINATION: #{destination}"
    Net::SCP.start(ip, nil) do |scp|
      files.collect do |f|
        scp.upload(f, destination)
      end.map(&:wait)
    end
  end

  def copy_from_server(files, destination)
    if File.directory?(destination)
      destination_dir = destination
      destination_is_directory = true
    else
      destination_is_directory = false
    end
    Net::SFTP.start(ip, nil) do |sftp|
      files.collect do |file|
        if destination_is_directory
          destination = File.join(destination_dir, File.basename(file))
        end
        sftp.download(file, destination)
      end
    end
  end

  def zip_file_creator_class
    SshZipFileCreator
  end

  def kill_process
    execute("kill -15 #{process_id}")
  end

  def restart
    if process_id
      logger.info "Killing process id #{process_id}"
      kill_process
    else
      logger.error "No process_id found for server #{id} - #{name}"
    end
    ssh_close
  end

  def shell_output_to_array(shell_output)
    shell_output.lines.map(&:chomp)
  end

  def ssh
    @ssh ||= Net::SSH::Simple.new({:host_name => ip})
  end

  def ssh_close
    ssh.close
    @ssh = nil
  end

end
