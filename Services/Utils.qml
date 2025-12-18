pragma Singleton

import Quickshell

Singleton {
    // TODO Implement AppName/Icon
    function notify(summary = '', body = '') {
        var test = Quickshell.execDetached(['notify-send', '-a', 'Clipboard', summary, body]);
    }

    // Ai code to move text over for indented blocks of copied text.
    function removeIndentation(text) {
        if (!text)
            return;
        let lines = text.split('\n');
        let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
        return lines.map(line => line.slice(minIndent)).join('\n');
    }
}
