import QtQuick
import QtQuick.Controls

ScrollView {
    id: root

    readonly property var contentLayout: {
        for (let i = 0; i < contentChildren.length; i++) {
            let child = contentChildren[i];
            if (child && child.hasOwnProperty('currentItem')) {
                return child;
            }
        }
        return null;
    }

    function scrollToTop() {
        ScrollBar.vertical.position = 0;
    }

    function scrollToItem() {
        if (!contentLayout || !contentLayout.currentItem) {
            return;
        }

        let item = contentLayout.currentItem;
        let contentItem = contentChildren[0];

        if (!contentItem) {
            return;
        }

        let itemY = item.mapToItem(contentItem, 0, 0).y;
        let itemHeight = item.height;

        let viewHeight = height;
        let contentHeight = contentItem.height;

        let scrollableHeight = contentHeight - viewHeight;

        if (scrollableHeight <= 0) {
            return;
        }

        let targetY = itemY - (viewHeight - itemHeight) / 2;

        targetY = Math.max(0, Math.min(targetY, scrollableHeight));

        // Position is the scroll offset normalized by contentHeight
        // Valid range is [0, 1.0 - size]
        let normalizedPosition = targetY / contentHeight;

        ScrollBar.vertical.position = normalizedPosition;
    }

    function scrollToItemTop() {
        if (!contentLayout || !contentLayout.currentItem) {
            return;
        }

        let item = contentLayout.currentItem;
        let contentItem = contentChildren[0];

        if (!contentItem) {
            return;
        }

        let itemY = item.mapToItem(contentItem, 0, 0).y;
        let viewHeight = height;
        let contentHeight = contentItem.height;
        let scrollableHeight = contentHeight - viewHeight;

        if (scrollableHeight <= 0) {
            return;
        }

        let targetY = Math.max(0, Math.min(itemY, scrollableHeight));

        // Position is the scroll offset normalized by contentHeight
        let normalizedPosition = targetY / contentHeight;

        ScrollBar.vertical.position = normalizedPosition;
    }

    function ensureItemVisible() {
        if (!contentLayout || !contentLayout.currentItem) {
            return;
        }

        let item = contentLayout.currentItem;
        let contentItem = contentChildren[0];

        if (!contentItem) {
            return;
        }

        let itemY = item.mapToItem(contentItem, 0, 0).y;
        let itemHeight = item.height;
        let viewHeight = height;
        let contentHeight = contentItem.height;
        let scrollableHeight = contentHeight - viewHeight;

        if (scrollableHeight <= 0) {
            return;
        }

        // Get current scroll position in absolute units
        let currentScrollY = ScrollBar.vertical.position * scrollableHeight;
        let currentViewTop = currentScrollY;
        let currentViewBottom = currentScrollY + viewHeight;

        // Check if item is already fully visible
        let itemTop = itemY;
        let itemBottom = itemY + itemHeight;

        if (itemTop >= currentViewTop && itemBottom <= currentViewBottom) {
            // Item is already fully visible, no need to scroll
            return;
        }

        // Calculate minimal scroll needed
        let targetY;
        if (itemTop < currentViewTop) {
            // Item is above viewport, scroll up to show it at top
            targetY = itemTop;
        } else {
            // Item is below viewport, scroll down to show it at bottom
            targetY = itemBottom - viewHeight;
        }

        targetY = Math.max(0, Math.min(targetY, scrollableHeight));

        // Position is the scroll offset normalized by contentHeight
        let normalizedPosition = targetY / contentHeight;

        ScrollBar.vertical.position = normalizedPosition;
    }
}
