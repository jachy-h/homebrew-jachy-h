class Umbragate < Formula
  desc "Local-first LLM gateway with dashboard and provider routing"
  homepage "https://github.com/jachy-h/umbra-gate"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/jachy-h/umbra-gate/releases/download/v0.8.1/umbragate_Darwin_arm64.tar.gz"
      sha256 "36c8d16cb17b004c63614667e5b9daebd0597fb09acd0c65ef25a38e35310968"
    else
      url "https://github.com/jachy-h/umbra-gate/releases/download/v0.8.1/umbragate_Darwin_x86_64.tar.gz"
      sha256 "9c32eaf1ff414d83c04d65dce74801caab98292f5a5cb6b847b55df7fe735f20"
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
