pragma Singleton

import QtQuick

import Quickshell

Singleton {

    property list<Setting> settings: []

    // What it does.
    // how to define a setting.
    //
    // property boolean aSetting: Settings.register({
    //     name: 'A Setting',
    //     value: true
    // })

    function register(setting: Setting): Setting {
        // if the setting exists in settings
        // return the values of the Setting
        // in the list of Settings.
        // - Compare by names, not entire object.
        //
        // If the setting isn't in the list
        // push the new setting to settings
        // and return the new setting.
        return setting;
    }

    function change(setting: Setting): Setting {
        // Push/Replace the exiting entry
        // in settings.
        return setting;
    }

    function getCategory(category: string): list<Setting> {
        // filter settings where all
        // objects are of the category type.
        return items
    }
}
