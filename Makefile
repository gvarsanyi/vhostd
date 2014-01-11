build: clean
	mkdir -p js/
	coffee -o js/ coffee/
	echo "#!/usr/bin/env node" | cat - js/vhostd.js > /tmp/vhostd.js
	mv /tmp/vhostd.js js/vhostd.js
	chmod a+x js/vhostd.js

clean:
	rm -rf js
