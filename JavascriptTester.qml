import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Constants
import qs.Components

FloatingWindow {
    id: root
    color: Colors.bgDim
    width: 800
    height: 600

    // JavaScript execution context
    QtObject {
        id: jsContext

        function execute(code) {
            var logs = [];

            // Override console methods to capture logs
            var originalConsole = {
                log: console.log,
                error: console.error,
                warn: console.warn
            };

            console.log = function (...args) {
                logs.push({
                    type: "log",
                    message: args.join(" ")
                });
                originalConsole.log.apply(console, args);
            };

            console.error = function (...args) {
                logs.push({
                    type: "error",
                    message: args.join(" ")
                });
                originalConsole.error.apply(console, args);
            };

            console.warn = function (...args) {
                logs.push({
                    type: "warn",
                    message: args.join(" ")
                });
                originalConsole.warn.apply(console, args);
            };

            try {
                // Create a function from the code and execute it
                var func = new Function(code);
                var result = func();

                // Restore original console
                console.log = originalConsole.log;
                console.error = originalConsole.error;
                console.warn = originalConsole.warn;

                return {
                    success: true,
                    result: result !== undefined ? String(result) : "undefined",
                    error: null,
                    logs: logs
                };
            } catch (e) {
                // Restore original console
                console.log = originalConsole.log;
                console.error = originalConsole.error;
                console.warn = originalConsole.warn;

                return {
                    success: false,
                    result: null,
                    error: String(e),
                    logs: logs
                };
            }
        }

        function openInEditor() {
            // Write code to temporary file
            var tempFile = "/tmp/quickshell_repl_" + Date.now() + ".js";
            var file = new DataStreamParser();
            // For now, just print - user can manually copy to editor
            console.log("Code to edit:", input.text);
        // In a real implementation, you'd write to file and call: Process.exec("$EDITOR", [tempFile])
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.marginSm
        spacing: Styles.marginSm

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Colors.bg1
            radius: Styles.radiusSm

            RowLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: Styles.marginSm

                TextStyled {
                    text: "JavaScript REPL"
                    font.pixelSize: 16
                    Layout.fillWidth: true
                }

                ButtonStyled {
                    implicitWidth: 100
                    implicitHeight: 30
                    defaultColor: Colors.green
                    hoverColor: Colors.bgGreen
                    radius: Styles.radiusSm

                    TextStyled {
                        text: "Execute"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                    }

                    onClicked: {
                        var result = jsContext.execute(input.text);
                        var outputText = "";

                        // Display console logs
                        if (result.logs && result.logs.length > 0) {
                            for (var i = 0; i < result.logs.length; i++) {
                                var log = result.logs[i];
                                var prefix = "";
                                if (log.type === "error")
                                    prefix = "[ERROR] ";
                                else if (log.type === "warn")
                                    prefix = "[WARN] ";
                                else
                                    prefix = "[LOG] ";
                                outputText += prefix + log.message + "\n";
                            }
                            outputText += "\n";
                        }

                        // Display result or error
                        if (result.success) {
                            outputText += "=> " + result.result;
                            output.text = outputText;
                            output.color = Colors.fg;
                        } else {
                            outputText += "Error: " + result.error;
                            output.text = outputText;
                            output.color = Colors.statusline3;
                        }
                    }
                }

                ButtonStyled {
                    implicitWidth: 80
                    implicitHeight: 30
                    defaultColor: Colors.bg2
                    hoverColor: Colors.bg3
                    radius: Styles.radiusSm

                    TextStyled {
                        text: "Clear"
                        anchors.centerIn: parent
                        font.pixelSize: 14
                    }

                    onClicked: {
                        input.text = "";
                        output.text = "";
                    }
                }

                ButtonStyled {
                    implicitWidth: 30
                    implicitHeight: 30
                    defaultColor: Colors.bg2
                    hoverColor: Colors.bg3
                    radius: Styles.radiusSm

                    TextStyled {
                        text: "📝"
                        anchors.centerIn: parent
                        font.pixelSize: 16
                    }

                    onClicked: {
                        // Copy to clipboard for now - open in external editor
                        console.log("Tip: Copy code and paste into your favorite editor with syntax highlighting");
                        console.log("Future: This will open in $EDITOR");
                    }
                }
            }
        }

        // Input area
        Rectangle {
            color: Colors.bg1
            Layout.fillHeight: true
            Layout.fillWidth: true
            radius: Styles.radiusSm
            border.color: Colors.bg4
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: 4

                TextStyled {
                    text: "Input:"
                    font.pixelSize: 12
                    color: Colors.grey1
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextArea {
                        id: input
                        color: Colors.fg
                        font.family: "RobotoMono Nerd Font Propo"
                        font.pixelSize: 14
                        selectByMouse: true
                        wrapMode: TextArea.Wrap

                        background: Rectangle {
                            color: "transparent"
                        }

                        placeholderText: "// Enter JavaScript code here...\n// Example:\nreturn 1 + 1;"
                        placeholderTextColor: Colors.grey0

                        Keys.onPressed: event => {
                            // Ctrl+Enter to execute
                            if (event.key === Qt.Key_Return && event.modifiers & Qt.ControlModifier) {
                                var result = jsContext.execute(input.text);
                                var outputText = "";

                                // Display console logs
                                if (result.logs && result.logs.length > 0) {
                                    for (var i = 0; i < result.logs.length; i++) {
                                        var log = result.logs[i];
                                        var prefix = "";
                                        if (log.type === "error")
                                            prefix = "[ERROR] ";
                                        else if (log.type === "warn")
                                            prefix = "[WARN] ";
                                        else
                                            prefix = "[LOG] ";
                                        outputText += prefix + log.message + "\n";
                                    }
                                    outputText += "\n";
                                }

                                // Display result or error
                                if (result.success) {
                                    outputText += "=> " + result.result;
                                    output.text = outputText;
                                    output.color = Colors.fg;
                                } else {
                                    outputText += "Error: " + result.error;
                                    output.text = outputText;
                                    output.color = Colors.statusline3;
                                }
                                event.accepted = true;
                            }
                        }
                    }
                }
            }
        }

        // Output area
        Rectangle {
            color: Colors.bg2
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            radius: Styles.radiusSm
            border.color: Colors.bg4
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Styles.marginSm
                spacing: 4

                TextStyled {
                    text: "Output:"
                    font.pixelSize: 12
                    color: Colors.grey1
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TextStyled {
                        id: output
                        width: parent.width
                        font.family: "RobotoMono Nerd Font Propo"
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        text: "// Output will appear here..."
                        color: Colors.grey0
                    }
                }
            }
        }

        // Info bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Colors.bg1
            radius: Styles.radiusSm

            TextStyled {
                anchors.centerIn: parent
                text: "Press Ctrl+Enter to execute • Use 'return' to output values • console.log() supported • 📝 for editor tip"
                font.pixelSize: 11
                color: Colors.grey1
            }
        }
    }
}
