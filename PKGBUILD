# Maintainer: shmilee <echo c2htaWxlZS56anVAZ21haWwuY29tCg==|base64 -d>

pkgname=vpn4zju
pkgver=2.0.r0
pkgrel=1
pkgdesc="A utility for ZJU school L2TP VPN."
arch=("any")
url="http://networking.zju.edu.cn/"
license=(GPLv2)
depends=("xl2tpd" "iproute")
optdepends=('python-keyring: for login/logout ZJUWLAN'
            'python-requests: for login/logout ZJUWLAN'
            'wicd: for auto login after connect ZJUWLAN')
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
