class Ruby193 < FPM::Cookery::Recipe
  description 'Libvirt'

  name 'libvirt'
  version '0.10.2'
  revision 1
  homepage 'http://libvirt.org/'
  source 'ftp://libvirt.org/libvirt/libvirt-0.10.2.tar.gz'
  sha256 '1fe69ae1268a097cc0cf83563883b51780d528c6493efe3e7d94c4160cc46977'

  vendor     'libvirt'
  license    'LGPL license'

  section 'libraries'

  platforms [:ubuntu, :debian] do
	build_depends 'build-essential', 'libgnutls-dev'
    depends 'libgnutls26'
  end

  platforms [:fedora, :redhat, :centos] do
	build_depends 'gcc', 'gcc-c++', 'make', 'gnutls-devel'
    depends 'gnutls'
  end

  def build
    configure :prefix => destdir
    make
  end

  def install
    make :install
  end
end
