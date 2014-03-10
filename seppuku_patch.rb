class Unicorn::HttpServer
  MEM_LIMIT = ENV['PUPPET_OMNIBUS_WMLIMIT'].to_i || 2_000_000_000

  alias :original_process_client :process_client
  def process_client(client)
    original_process_client client
    kill_mem
  end

  def kill_mem
    Process.exit(121) if `ps -o rss= -p #{Process.pid}`.to_i > MEM_LIMIT
  rescue
    Process.exit(122)
  end
end
