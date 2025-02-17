require "language/node"

class BalenaCli < Formula
  desc "The official balena CLI tool"
  homepage "https://www.balena.io/docs/reference/cli/"
  # balena-cli should only be updated every 10 releases on multiples of 10
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-12.18.0.tgz"
  sha256 "92080d65d98eb0e1a402a7222d9fe205c3ca321b028f817c8d0331d026fcbe5c"
  license "Apache-2.0"

  livecheck do
    url :stable
  end

  bottle do
    sha256 "b49085b93236255a018338a2808ea64d034bb06fc3c1c517ce2126541ffd408f" => :catalina
    sha256 "74c04a77009ec15356c16d20a301de065c124c8e4f70ed556cc86e2dabfe551a" => :mojave
    sha256 "e272400874dece2e648e8cd39417217868d7eeb8df7be25a4c0f3331c110749c" => :high_sierra
    sha256 "25c82b2b07bc1b169cfdadcb3af7cef3737951dbfb5ffd2a056f33484e974d52" => :x86_64_linux
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "Logging in to balena-cloud.com",
      shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
  end
end
