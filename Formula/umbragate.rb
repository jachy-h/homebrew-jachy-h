class Umbragate < Formula
  desc "Local-first LLM gateway with dashboard and provider routing"
  homepage "https://github.com/jachy-h/umbra-gate"
  version "0.8.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jachy-h/umbra-gate/releases/download/v0.8.0/umbragate_Darwin_arm64.tar.gz"
      sha256 "7188ca62233f4ab8483faa1c6c85a53499a9831520bea5f3556b2ecec0eca3e3"
    else
      url "https://github.com/jachy-h/umbra-gate/releases/download/v0.8.0/umbragate_Darwin_x86_64.tar.gz"
      sha256 "943a78d2abe6474fb3873e817d1bb00b9bef13ca78ccf69f7de088e4086689a6"
    end
  end

  def install
    bin.install "umbragate"
    pkgshare.install "config.yaml"
  end

  service do
    run [opt_bin/"umbragate", "run"]
    keep_alive true
    log_path var/"log/umbragate.log"
    error_log_path var/"log/umbragate.log"
  end

  def caveats
    <<~EOS
      Example config installed to:
        ~/.umbragate/config.yaml (created on first launch)

      Homebrew install stores config and database in:
        ~/.umbragate/

      Quick start:
        umbragate start

      Foreground mode:
        umbragate run

      Background mode:
        brew services start umbragate
        # or
        umbragate start
    EOS
  end

  test do
    output = shell_output("#{bin}/umbragate --help")
    assert_match "Usage: umbragate", output
  end
end
