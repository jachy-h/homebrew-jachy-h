class LanCopy < Formula
  desc "Zero-dependency LAN file and text sharing tool"
  homepage "https://github.com/jachy-h/lan-copy"
  url "https://github.com/jachy-h/lan-copy/releases/download/v0.8.1/Lan-Copy-macOS-Apple-Silicon.tar.gz"
  sha256 "fe6cb38a213708405f9051c78f17bbca426053397003862953757eee001c9f37"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "Lan-Copy-macOS-arm64/lan-copy"
  end

  service do
    run [opt_bin/"lan-copy", "-dir", var/"lan-copy"]
    keep_alive true
    working_dir var
    log_path var/"log/lan-copy.log"
    error_log_path var/"log/lan-copy.log"
  end

  def caveats
    <<~EOS
      Start in the background:
        brew services start lan-copy

      Then open http://localhost:8080

      Upgrade with Homebrew rather than the in-app updater, which would replace
      files inside the Homebrew Cellar:
        brew upgrade lan-copy

      Run in the foreground with your own directory:
        lan-copy -dir ~/共享文件夹-lancopy
    EOS
  end

  test do
    port = free_port
    (testpath/"share").mkpath
    pid = fork do
      exec bin/"lan-copy", "-listen", "127.0.0.1:#{port}", "-dir", testpath/"share"
    end

    begin
      20.times do
        sleep 0.5
        break if system("curl", "-fsS", "http://127.0.0.1:#{port}/healthz", out: File::NULL, err: File::NULL)
      end
      assert_equal "ok", shell_output("curl -fsS http://127.0.0.1:#{port}/healthz").strip
      app = JSON.parse(shell_output("curl -fsS http://127.0.0.1:#{port}/api/app"))
      assert_match(/\A\d+\.\d+\.\d+/, app["version"])
      assert_equal "darwin", app["os"]
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
