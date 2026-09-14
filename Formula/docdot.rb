class Docdot < Formula
  desc "Run and compare PDF parsers locally"
  homepage "https://docdot.ai/"
  url "https://dl.docdot.ai/releases/docdot/0.1.3/docdot-darwin-arm64", using: :nounzip
  version "0.1.3"
  sha256 "7443ceedc0c97177c43f70de1e16ede52f075462dcaf83be5f37c8e43f8525a8"

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
