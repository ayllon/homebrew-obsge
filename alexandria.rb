class Alexandria < Formula
  desc "SDC-CH common library for the Euclid project"
  homepage "https://github.com/astrorama/Alexandria"
  url "https://github.com/astrorama/Alexandria/archive/2.10_p2.tar.gz"
  version "2.10"
  depends_on "cmake" => :build
  depends_on "ccfits"
  depends_on "cfitsio"
  depends_on "Elements"

  def install
    mkdir "build" do
      ENV["CMAKE_PROJECT_PATH"] = "#{HOMEBREW_PREFIX}/lib/cmake/ElementsProject"
      system "cmake", "..", "-DELEMENTS_BUILD_TESTS=NO", "-DUSE_SPHINX=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "false"
  end
end
