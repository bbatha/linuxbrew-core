class Fabio < Formula
  desc "Zero-conf load balancing HTTP(S) router"
  homepage "https://github.com/fabiolb/fabio"
  url "https://github.com/fabiolb/fabio/archive/v1.5.14.tar.gz"
  sha256 "4d0be0922a371383912a0fcf2bcd325a91aad9fc9579dcda6dbc075c7dbbbc19"
  license "MIT"
  head "https://github.com/fabiolb/fabio.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "197702e971927d8224bee4a7db06d7e600bd2860bbc055f1df19e20ad2e63358" => :catalina
    sha256 "d272c77961183cb8361d588c041161de1ecdd729e5857f19e3d4822ddaaf657c" => :mojave
    sha256 "627bbe4f66761102c57375c327d4352a20825b744e9a653b42c308f3d08e4d45" => :high_sierra
    sha256 "e22d77d282624d6b84cf06535e15aeea646c724de7f337e65537009c2b45fc39" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "consul"

  def install
    system "go", "build", "-ldflags", "-s -w", "-trimpath", "-o", bin/"fabio"
    prefix.install_metafiles
  end

  test do
    require "socket"
    require "timeout"

    CONSUL_DEFAULT_PORT = 8500
    FABIO_DEFAULT_PORT = 9999
    LOCALHOST_IP = "127.0.0.1".freeze

    def port_open?(ip_address, port, seconds = 1)
      Timeout.timeout(seconds) do
        TCPSocket.new(ip_address, port).close
      end
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Timeout::Error
      false
    end

    if !port_open?(LOCALHOST_IP, FABIO_DEFAULT_PORT)
      if !port_open?(LOCALHOST_IP, CONSUL_DEFAULT_PORT)
        fork do
          exec "consul agent -dev -bind 127.0.0.1"
          puts "consul started"
        end
        sleep 30
      else
        puts "Consul already running"
      end
      fork do
        exec "#{bin}/fabio &>fabio-start.out&"
        puts "fabio started"
      end
      sleep 10
      assert_equal true, port_open?(LOCALHOST_IP, FABIO_DEFAULT_PORT)
      if OS.mac?
        system "killall", "fabio" # fabio forks off from the fork...
      else
        # killall may not be installed on Linux
        system "kill -9 $(pgrep fabio)"
      end
      system "consul", "leave"
    else
      puts "Fabio already running or Consul not available or starting fabio failed."
      false
    end
  end
end
