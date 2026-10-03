
.PHONY: iso
iso:
	sh ./files/iso/iso.sh

.PHONY: iso-remote
iso-remote:
	sh ./files/iso/iso.sh --remote
