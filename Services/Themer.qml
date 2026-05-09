import QtQuick

import qs.Settings

Item {
    property string variant: 'primary'

   property string main: {
       if (variant === 'primary') return Colors.primary
       if (variant === 'secondary') return Colors.secondary
       if (variant === 'tertiary') return Colors.tertiary
       return Colors.onBackground
   }

   property string containerText: {
       if (variant === 'primary') return Colors.onPrimary
       if (variant === 'secondary') return Colors.onSecondary
       if (variant === 'tertiary') return Colors.onTertiary
       return Colors.background
   }

   property string mainContainer: {
       if (variant === 'primary') return Colors.primaryContainer
       if (variant === 'secondary') return Colors.secondaryContainer
       if (variant === 'tertiary') return Colors.tertiaryContainer
       return Colors.backgroundLighter
   }
}
