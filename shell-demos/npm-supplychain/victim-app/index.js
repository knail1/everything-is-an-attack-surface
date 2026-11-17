// The victim's actual code. It never even runs during the attack: the postinstall
// hook fired the moment `npm install` resolved the dependency.
const { pad } = require('left-pad-helper');
console.log('[victim] padded:', pad('7', 5));
