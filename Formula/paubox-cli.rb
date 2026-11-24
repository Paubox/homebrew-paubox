class PauboxCli < Formula
  desc "Official CLI for the Paubox HIPAA-compliant email API"
  homepage "https://github.com/Paubox/paubox-cli"
  url "https://registry.npmjs.org/paubox-cli/-/paubox-cli-2.1.0.tgz"
  sha256 "8e586c889574011c2b6d0a7af40cd8763eadf822bd48c0627c2cb0fee9046637"
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
