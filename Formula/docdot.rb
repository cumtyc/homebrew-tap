class Docdot < Formula
  desc "Run and compare PDF parsers locally"
  homepage "https://docdot.ai/"
  url "https://dl.docdot.ai/releases/docdot/0.2.0/docdot-darwin-arm64", using: :nounzip
  version "0.2.0"
  sha256 "9f27a0efd8786e4b6525e3230904e7fa9f2ecd7a902876f7b26700cd4bbd0468"

  livecheck do
    url "https://dl.docdot.ai/releases/docdot/latest/version.txt"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "docdot-darwin-arm64" => "docdot"
    (bin/"docdot").chmod 0755
  end

  def caveats
    <<~EOS
      To upgrade DocDot when installed with Homebrew, run:
        brew upgrade docdot
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docdot --version")
  end
end
