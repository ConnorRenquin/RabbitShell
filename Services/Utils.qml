import Quickshell

import QtQuick

Item {
    width: 0
    height: 0

    // TODO Implement AppName/Icon
    function notify({summary = '', body = '', from = ''}) {
        var test = Quickshell.execDetached(['notify-send', '-a', from, summary, body]);
    }

    // Ai code to move text over for indented blocks of copied text.
    function removeIndentation(text) {
        if (!text)
            return;
        let lines = text.split('\n');
        let minIndent = Math.min(...lines.filter(line => line.trim().length > 0).map(line => line.match(/^\s*/)[0].length));
        return lines.map(line => line.slice(minIndent)).join('\n');
    }

    // Fuzzy search function that matches characters in order
    // Returns { matches: bool, score: number }
    function fuzzySearch(query, text) {
        if (!query || query.trim() === '') {
            return {
                matches: true,
                score: 1
            };
        }

        if (!text) {
            return {
                matches: false,
                score: 0
            };
        }

        query = query.toLowerCase();
        text = text.toLowerCase();

        let queryIndex = 0;
        let textIndex = 0;
        let score = 0;
        let consecutiveMatches = 0;

        while (queryIndex < query.length && textIndex < text.length) {
            if (query[queryIndex] === text[textIndex]) {
                queryIndex++;
                consecutiveMatches++;
                // Bonus points for consecutive matches
                score += consecutiveMatches * 2;
            } else {
                consecutiveMatches = 0;
                score -= 1;
            }
            textIndex++;
        }

        // Check if all query characters were found
        const matches = queryIndex === query.length;

        // Normalize score
        if (matches) {
            score += (query.length * 10); // Base score for matching
            score -= (text.length - query.length) * 0.5; // Penalty for longer texts
        } else {
            score = 0;
        }

        return {
            matches: matches,
            score: score
        };
    }
}
