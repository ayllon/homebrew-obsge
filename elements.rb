# Documentation: https://docs.brew.sh/Formula-Cookbook
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
class Elements < Formula
  include Language::Python::Virtualenv

  desc "C++/Python Build Framework"
  homepage ""
  version "5.4"
  url "https://github.com/degauden/Elements/archive/5.4.tar.gz"
  depends_on "python" => "3"
  depends_on "cmake"
  depends_on "pkg-config"
  depends_on "boost"
  depends_on "log4cpp"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/37/1b/b25507861991beeade31473868463dad0e58b1978c209de27384ae541b0b/setuptools-40.6.3.zip"
    sha256 "3b474dad69c49f0d2d86696b68105f3a6f195f7ab655af12ef9a9c326d2b08f8"
  end

  resource "pytest" do
    url "https://files.pythonhosted.org/packages/db/88/11b1a23db24d29556b5a0fa661bf7f2205d7b5f9bd2c9f578e5dd4997441/pytest-3.9.1.tar.gz"
    sha256 "8c827e7d4816dfe13e9329c8226aef8e6e75d65b939bc74fda894143b6d1df59"
  end

  def install
    inreplace "cmake/ElementsLocations.cmake", "set(lib_install_suff lib64)", "set(lib_install_suff lib)"

    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resource("setuptools")
    venv.pip_install resource("pytest")

    #ENV.prepend_create_path "PATH", libexec/"bin"
    #ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"

    mkdir "build" do
      system "cmake", "..", "-DPYTHON_EXPLICIT_VERSION=3", "-DELEMENTS_BUILD_TESTS=OFF", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "AddCppClass --help"
  end
end
