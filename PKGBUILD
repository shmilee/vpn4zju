# Maintainer: shmilee <echo c2htaWxlZS56anVAZ21haWwuY29tCg==|base64 -d>

pkgname=vpn4zju
pkgver=1.1.r2.g09462e1
pkgrel=1
pkgdesc="A utility for ZJU school L2TP VPN."
arch=("any")
url="http://networking.zju.edu.cn/"
license=(GPLv2)
depends=("xl2tpd" "iproute")
makedepends=('git')
source=("git+https://github.com/shmilee/$pkgname.git")
md5sums=('SKIP')

pkgver() {
  cd "${srcdir}/${pkgname}"
  git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

package() {
    cd "$srcdir/$pkgname"
    make DESTDIR="${pkgdir}" install
}
