all: install

install:
	install -Dm755 vpn4zju.sh $(DESTDIR)/usr/bin/vpn4zju
	install -Dm755 zjuwlan.py $(DESTDIR)/usr/bin/zjuwlan
	install -Dm644 vpn4zju.service $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	install -Dm644 options.xl2tpd.zju $(DESTDIR)/etc/ppp/options.xl2tpd.zju
	install -Dm755 wicd-postconnect.sh $(DESTDIR)/etc/wicd/scripts/postconnect/zjuwlan-login
	install -Dm644 info.md readme.md -t $(DESTDIR)/usr/share/doc/vpn4zju/

uninstall:
	rm -f $(DESTDIR)/usr/bin/vpn4zju
	rm -f $(DESTDIR)/usr/bin/zjuwlan
	rm -f $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	rm -f $(DESTDIR)/etc/ppp/options.xl2tpd.zju
	rm -f $(DESTDIR)/etc/wicd/scripts/postconnect/zjuwlan-login
	rm -rf $(DESTDIR)/usr/share/doc/vpn4zju/
