# Maintainer: shmilee <echo c2htaWxlZS56anVAZ21haWwuY29tCg==|base64 -d>

pkgname=vpn4zju
pkgver=1.0
pkgrel=1
pkgdesc="A utility for ZJU school L2TP VPN."
arch=("any")
url="http://networking.zju.edu.cn/"
license=(GPLv2)
depends=("xl2tpd" "iproute")
source=("https://github.com/shmilee/$pkgname/archive/v$pkgver.tar.gz")
md5sums=('eeeeeeeeeeeee')

package() {
    cd "$srcdir/$pkgname-$pkgver"
    make DESTDIR="${pkgdir}" install
}
