all: install

install:
	install -Dm755 vpn4zju $(DESTDIR)/usr/bin/vpn4zju
	install -Dm644 vpn4zju.service $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	install -Dm644 options.xl2tpd.zju $(DESTDIR)/etc/ppp/options.xl2tpd.zju

uninstall:
	rm -rf $(DESTDIR)/usr/bin/vpn4zju
	rm -rf $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	rm -rf $(DESTDIR)/etc/ppp/options.xl2tpd.zju
