import Quickshell
import QtQuick

Item {
    width: 0
    height: 0

    function enterPressed(event) {
        return [Qt.Key_Return, Qt.Key_Enter].includes(event.key);
    }

    function escapePressed(event) {
        return event.key === Qt.Key_Escape;
    }

    // Escape or Q
    function quitPressed(event) {
        return [Qt.Key_Escape, Qt.Key_Q].includes(event.key);
    }

    function upPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Up) return true;
        if (event.key === Qt.Key_K) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function downPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Down) return true;
        if (event.key === Qt.Key_J) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function leftPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Left) return true;
        if (event.key === Qt.Key_H) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function rightPressed(event, ctrlRequired = false) {
        if (event.key === Qt.Key_Right) return true;
        if (event.key === Qt.Key_L) {
            if (ctrlRequired) {
                return (event.modifiers & Qt.ControlModifier) !== 0;
            }
            return true;
        }
        return false;
    }

    function tabPressed(event) {
        return event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier);
    }

    function backtabPressed(event) {
        return event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier));
    }

    function slashPressed(event) {
        return event.key === Qt.Key_Slash;
    }

    function mPressed(event) {
        return event.key === Qt.Key_M;
    }

    function cPressed(event) {
        return event.key === Qt.Key_C;
    }
}
