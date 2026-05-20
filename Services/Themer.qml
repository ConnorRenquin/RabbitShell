import QtQuick

import qs.Settings

Item {
    property string settingName
    property string variant: {
        if (!settingName) return 'regular';
        const s = Settings.settings.find(s => s.name === settingName);
        return s ? s.value : 'regular';
    }

    Component.onCompleted: {
        if (settingName) {
            Settings.register({
                name: settingName,
                options: ['primary', 'secondary', 'tertiary', 'regular'],
                value: 'regular',
                category: 'colors'
            });
        }
    }

    property string text: {
        if (variant === 'primary')
            return Colors.primary;
        if (variant === 'secondary')
            return Colors.secondary;
        if (variant === 'tertiary')
            return Colors.tertiary;
        return Colors.onBackground;
    }

    property string background: {
        if (variant === 'primary')
            return Colors.onPrimary;
        if (variant === 'secondary')
            return Colors.onSecondary;
        if (variant === 'tertiary')
            return Colors.onTertiary;
        return Colors.background;
    }

    property string foreground: {
        if (variant === 'primary')
            return Colors.primaryContainer;
        if (variant === 'secondary')
            return Colors.secondaryContainer;
        if (variant === 'tertiary')
            return Colors.tertiaryContainer;
        return Colors.backgroundLighter;
    }
}
