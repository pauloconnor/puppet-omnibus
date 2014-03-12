class Unicorn::HttpServer
  # memory limit in KILOBYTES
  MEM_LIMIT = if (limit = ENV['PUPPET_OMNIBUS_WMLIMIT'].to_i) == 0
    500_000
  else
    limit
  end

  REQ_LIMIT = if (limit = ENV['PUPPET_OMNIBUS_WRLIMIT'].to_i) == 0
    1000
  else
    limit
  end

  alias :original_process_client :process_client
  def process_client(client)
    original_process_client client
    kill_mem
    kill_req
  end

  def kill_mem
    Process.exit(121) if `ps -o rss= -p #{Process.pid}`.to_i > MEM_LIMIT
  rescue
    Process.exit(122)
  end

  def kill_req
    @requests_processed ||= 0
    @requests_processed += 1
    Process.exit(123) if @requests_processed > REQ_LIMIT
  end
end
