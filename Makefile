.PHONY: install clean debug

CFLAGS = -static -no-pie -fno-pic -fno-plt -s -Wall -Wextra -Werror
CFLAGS_DEBUG = -static -no-pie -fno-pic -fno-plt -g -O0 -Wall -Wextra -Werror

./mutealsa: ./mutealsa.c | ./musl ./libalsa
	./musl/bin/gcc $(CFLAGS) -o ./mutealsa -I"./libalsa/build/include" ./mutealsa.c "./libalsa/build/lib/libasound.a"
	objcopy --only-section=.init --only-section=.text --only-section=.fini --only-section=.rodata --only-section=.init_array --only-section=.fini_array --only-section=.data --only-section=.bss --only-section=.data.rel.ro --only-section=.eh_frame --only-section=.shstrtab ./mutealsa ./mutealsa

debug: ./mutealsa_debug
./mutealsa_debug: ./mutealsa.c | ./musl ./libalsa
	./musl/bin/gcc $(CFLAGS_DEBUG) -o ./mutealsa_debug -I"./libalsa/build/include" ./mutealsa.c "./libalsa/build/lib/libasound.a"

./libalsa: ./musl
	@echo "Cloning LibAlsa..."
	@git clone https://github.com/alsa-project/alsa-lib.git ./libalsa/ 1>/dev/null 2>&1
	@echo "Building LibAlsa..."
	@cd ./libalsa/ && autoreconf -i 1>/dev/null 2>&1
	@cd ./libalsa/ && CC="$$(realpath "../musl/bin/gcc")" ./configure --host=x86_64-linux-musl --prefix='/usr' --disable-shared --enable-static --disable-python --disable-hwdep --disable-topology --disable-aload --disable-seq --disable-rawmidi --disable-ucm --disable-old-symbols --without-versioned 1>/dev/null 2>&1
	@cd ./libalsa/ && make -j$$(nproc) 1>/dev/null 2>&1
	@cd ./libalsa/ && make DESTDIR="$$(realpath "./build/")" install 1>/dev/null 2>&1
	@mv ./libalsa/build/usr/* ./libalsa/build/
	@rm -r ./libalsa/build/usr/
	@rm -rf ./libalsa/build/bin/
	@rm -rf ./libalsa/build/lib/pkgconfig/
	@rm -f ./libalsa/build/lib/libasound.la
	@rm -rf ./libalsa/build/share/aclocal/

./musl:
	@echo "Downloading Musl..."
	@curl https://musl.cc/x86_64-linux-musl-native.tgz -o ./musl.tgz --progress-bar
	@echo "Extracting Musl..."
	@tar -xvf ./musl.tgz 1>/dev/null 2>&1
	@rm ./musl.tgz
	@mv ./x86_64-linux-musl-native ./musl

install:
	@cp ./mutealsa /usr/lib/systemd/system-sleep/mutealsa
	@chmod 0755 /usr/lib/systemd/system-sleep/mutealsa
	@chown +0:+0 /usr/lib/systemd/system-sleep/mutealsa
	@echo "Installed ./mutealsa into /usr/lib/systemd/system-sleep/mutealsa"

clean:
	rm -rf ./musl/ ./libalsa/ ./mutealsa