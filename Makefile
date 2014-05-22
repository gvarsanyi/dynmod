
compile:
	chmod a+x coffee/dynmod-cli.coffee
	chmod a+x coffee/dynmod-run.coffee
	coffee -o js/ coffee/
	echo '#!/usr/bin/env node' | cat - js/dynmod-cli.js > js/_dynmod-cli.js
	mv js/_dynmod-cli.js js/dynmod-cli.js
	echo '#!/usr/bin/env node' | cat - js/dynmod-run.js > js/_dynmod-run.js
	mv js/_dynmod-run.js js/dynmod-run.js
	chmod a+x js/dynmod-cli.js
	chmod a+x js/dynmod-run.js
