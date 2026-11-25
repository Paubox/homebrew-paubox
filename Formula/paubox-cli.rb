class PauboxCli < Formula
  desc "Official CLI for the Paubox HIPAA-compliant email API"
  homepage "https://github.com/Paubox/paubox-cli"
  url "https://registry.npmjs.org/paubox-cli/-/paubox-cli-2.1.1.tgz"
  sha256 "6d20789c7e215c3da112e0aaa8877d0b656dcdd419dcfb95df2f2ea2f1eba674"
  license "Apache-2.0"

  depends_on "node"

  def install
    # std_npm_args strips prepack/prepare/postpack from package.json and
    # installs from a tarball (not the source directory), which avoids
    # npm 5.0+ creating symlinks back to the Homebrew build tempdir.
    # ignore_scripts: false lets keytar's postinstall fetch its native binary.
    system "npm", "install", *std_npm_args(ignore_scripts: false)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/paubox --version")
    assert_match "Usage:", shell_output("#{bin}/paubox --help")
  end
end
