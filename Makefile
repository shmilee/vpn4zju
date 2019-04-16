all: install

install:
	install -Dm755 vpn4zju.sh $(DESTDIR)/usr/bin/vpn4zju
	install -Dm755 zjuwlan.py $(DESTDIR)/usr/bin/zjuwlan
	install -Dm644 vpn4zju.service $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	install -Dm644 options.xl2tpd.zju $(DESTDIR)/etc/ppp/options.xl2tpd.zju
	install -Dm755 wicd-postconnect.sh $(DESTDIR)/etc/wicd/scripts/postconnect/zjuwlan-login

uninstall:
	rm -rf $(DESTDIR)/usr/bin/vpn4zju
	rm -rf $(DESTDIR)/usr/bin/zjuwlan
	rm -rf $(DESTDIR)/usr/lib/systemd/system/vpn4zju.service
	rm -rf $(DESTDIR)/etc/ppp/options.xl2tpd.zju
	rm -rf $(DESTDIR)/etc/wicd/scripts/postconnect/zjuwlan-login
