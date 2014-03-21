
compile:
	chmod a+x coffee/dynmod-cli.coffee
	coffee -o js/ coffee/
	echo '#!/usr/bin/env node' | cat - js/dynmod-cli.js > js/_dynmod-cli.js
	mv js/_dynmod-cli.js js/dynmod-cli.js
	chmod a+x js/dynmod-cli.js
