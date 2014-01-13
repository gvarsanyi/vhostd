build: clean
	@mkdir -p js/
	@echo "Compiling coffee-script"
	@coffee -o js/ coffee/
	@echo "Adding header to runnable JS files"
	@echo "#!/usr/bin/env node" | cat - js/vhostd.js > /tmp/vhostd.js
	@mv /tmp/vhostd.js js/vhostd.js
	@echo "#!/usr/bin/env node" | cat - js/vhostd-service.js > /tmp/vhostd-service.js
	@mv /tmp/vhostd-service.js js/vhostd-service.js
	@echo "Set executable bit for runnable JS files"
	@chmod a+x js/vhostd*.js
	@echo " -- DONE"

clean:
	@echo "Clening JS dir"
	@rm -rf js
