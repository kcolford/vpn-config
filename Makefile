GPG = gpg --default-recipient-self
OPENSSL = openssl
OPENVPN = openvpn
SHELL = /bin/bash
MAKE_ENC = umask 077; [ -f $@.gpg ] && exec $(GPG) -o $@ -d $@.gpg; trap "$(GPG) -o $@.gpg -e $@" EXIT;

all:

include config.mk
export CA = $(ca)

all: $(ca).crt

clean:
	git clean -fX

distclean:
	git clean -fx

dh.pem:
	$(OPENSSL) dhparam -out $@ $(ks)

make_config.sh: $(ca).crt $(ca).secret dh.pem
	touch $@

server-%.conf: %.$(ca).crt %.$(ca).key server.conf make_config.sh
	./make_config.sh server.conf $*.$(ca) > $@

client-%.conf: %.$(ca).crt %.$(ca).key client.conf make_config.sh
	./make_config.sh client.conf $*.$(ca) > $@

$(ca).crt: $(ca).key
	$(OPENSSL) req -new -x509 -subj "/CN=$(ca)" -days $(ds) -key $< -out $@

%.crt: %.csr $(ca).key $(ca).crt
	$(OPENSSL) x509 -days $(ds) -req -in $< -CA $(ca).crt -CAkey $(ca).key -CAcreateserial -out $@

%.csr: %.key
	$(OPENSSL) req -new -subj "/CN=$*" -key $< -out $@

$(ca).secret:
	$(MAKE_ENC) $(OPENVPN) --genkey --secret $@

%.key:
	$(MAKE_ENC) $(OPENSSL) genrsa -out $@ $(ks)
