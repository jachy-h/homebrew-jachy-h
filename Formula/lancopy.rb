class Lancopy < Formula
  desc "Zero-dependency LAN file and text sharing tool"
  homepage "https://github.com/jachy-h/lan-copy"
  url "https://github.com/jachy-h/lan-copy/releases/download/v0.15.0-build1/Lan-Copy-macOS-Apple-Silicon.tar.gz"
  sha256 "c3f9587382b99cba9e7b66e12b14afe2c6f2417bcce39cb196803eb986ab25e9"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "lan-copy" => "lancopy"
  end

  service do
    run [opt_bin/"lancopy", "-dir", var/"lancopy"]
    keep_alive true
    working_dir var
    log_path var/"log/lancopy.log"
    error_log_path var/"log/lancopy.log"
  end

  def caveats
    <<~EOS
      Start in the background:
        brew services start lancopy

      Then open http://localhost:8080

      Upgrade with Homebrew rather than the in-app updater, which would replace
      files inside the Homebrew Cellar:
        brew upgrade lancopy

      Run in the foreground with your own directory:
        lancopy -dir ~/共享文件夹-lancopy
    EOS
  end

  test do
    port = free_port
    (testpath/"share").mkpath
    pid = fork do
      exec bin/"lancopy", "-listen", "127.0.0.1:#{port}", "-dir", testpath/"share"
    end

    begin
      20.times do
        sleep 0.5
        break if quiet_system("curl", "-fsS", "-o", File::NULL, "http://127.0.0.1:#{port}/healthz")
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
