class Docdot < Formula
  desc "Run and compare PDF parsers locally"
  homepage "https://docdot.ai/"
  url "https://dl.docdot.ai/releases/docdot/0.1.4/docdot-darwin-arm64", using: :nounzip
  version "0.1.4"
  sha256 "07a6b3523bec9f759e28dba8e9129ca46765f9ded8c2ddfdd0bde3dd3dc053ea"

  livecheck do
    url "https://dl.docdot.ai/releases/docdot/latest/version.txt"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on arch: :arm64
  depends_on :macos

  resource "docdot-converter" do
    url "https://dl.docdot.ai/releases/docdot-converter/0.1.4/docdot-converter-darwin-arm64", using: :nounzip
    sha256 "362e6d7990f7fc613f9d16951b295f443a5cd6ade5e93bf54cf4f4abcf60ab8f"
  end

  def install
    bin.install "docdot-darwin-arm64" => "docdot"
    (bin/"docdot").chmod 0755

    resource("docdot-converter").stage do
      bin.install "docdot-converter-darwin-arm64" => "docdot-converter"
      (bin/"docdot-converter").chmod 0755
    end
  end

  def caveats
    <<~EOS
      To upgrade DocDot when installed with Homebrew, run:
        brew upgrade docdot
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docdot --version")
    assert_match version.to_s, shell_output("#{bin}/docdot-converter --version")
  end
end
