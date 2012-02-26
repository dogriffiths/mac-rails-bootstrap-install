# File for managing Rails installs

RUBY_VERSION = 1.9.3
READLINE_VERSION = 6.2
SQLITE_VERSION = 3070900
RVM_DIR = $(HOME)/.rvm

info:
	echo "Usually you'll want 'make clean install-rails'"

clean:
	rm -rf $(RVM_DIR)

$(RVM_DIR):
	(curl -s 'https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer' | bash -s stable) &&\
	  echo "Now log out and log back in"

readline-$(READLINE_VERSION).tar.gz:
	curl -O ftp://ftp.gnu.org/gnu/readline/readline-$(READLINE_VERSION).tar.gz

readline-$(READLINE_VERSION): readline-$(READLINE_VERSION).tar.gz
	tar xzvf readline-$(READLINE_VERSION).tar.gz

$(HOME)/.rvm/include/readline: $(RVM_DIR) readline-$(READLINE_VERSION)
	cd readline-$(READLINE_VERSION) &&\
	./configure --prefix=$(RVM_DIR) &&\
	make &&\
	make install &&\
	cd .. &&\
	rm -rf readline-$(READLINE_VERSION)

sqlite-autoconf-$(SQLITE_VERSION).tar.gz:
	curl -O http://www.sqlite.org/sqlite-autoconf-$(SQLITE_VERSION).tar.gz

sqlite-autoconf-$(SQLITE_VERSION): sqlite-autoconf-$(SQLITE_VERSION).tar.gz
	tar xzvf sqlite-autoconf-$(SQLITE_VERSION).tar.gz

$(HOME)/.rvm/include/sqlite3.h: $(RVM_DIR) sqlite-autoconf-$(SQLITE_VERSION)
	cd sqlite-autoconf-$(SQLITE_VERSION) &&\
	CFLAGS='-arch i686 -arch x86_64' LDFLAGS='-arch i686 -arch x86_64' &&\
	./configure --disable-dependency-tracking --prefix=$(RVM_DIR) &&\
	make &&\
	make install &&\
	cd .. &&\
	rm -rf sqlite-autoconf-$(SQLITE_VERSION)

remove-ruby: $(RVM_DIR)
	. $(RVM_DIR)/scripts/rvm && rvm remove $(RUBY_VERSION)

fix-ruby: $(RVM_DIR) remove-ruby $(HOME)/.rvm/include/readline $(HOME)/.rvm/include/sqlite3.h
	. $(RVM_DIR)/scripts/rvm &&\
	   rvm install $(RUBY_VERSION) -C --enable-shared,--with-readline-dir=$(HOME)/.rvm,--build=x86_64-apple-darwin10

configure-rvm: $(RVM_DIR)
	grep rvm ~/.bash_profile || (echo "\n. $(RVM_DIR)/scripts/rvm" >>\
	  ~/.bash_profile) && echo "Now log out and log back in"

install-ruby: $(RVM_DIR) configure-rvm
	. $(RVM_DIR)/scripts/rvm && (ruby -v | grep $(RUBY_VERSION) > /dev/null) || rvm install $(RUBY_VERSION)

install-rails: $(RVM_DIR) configure-rvm install-ruby
	. $(RVM_DIR)/scripts/rvm && rvm use $(RUBY_VERSION) \
	&& rvm --default $(RUBY_VERSION) && gem install rails \
	&& echo "Rails installed. Now log out and back in again"