class PauboxCli < Formula
  desc "Official CLI for the Paubox HIPAA-compliant email API"
  homepage "https://github.com/Paubox/paubox-cli"
  url "https://registry.npmjs.org/paubox-cli/-/paubox-cli-0.1.3.tgz"
  sha256 "388f3b0f8fb863f1a8e01200b253b700419fbcfb0e209f338bff8d62fb9eeb86"
  license "Apache-2.0"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/paubox --version")
  end
end
