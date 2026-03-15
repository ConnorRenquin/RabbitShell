#!/bin/sh

echo "=== Notification Flood Test ==="
echo "Sending all notifications instantly..."
echo ""

notify-send "File Manager" "Click to open Dolphin file manager" \
  --app-name="Files" \
  --icon=system-file-manager \
  --urgency=normal \
  --action="open=Open Dolphin" \
  --action="cancel=Cancel" &

notify-send "New Message" "You have a new message. Click to reply." \
  --app-name="Messenger" \
  --icon=mail-unread \
  --urgency=normal \
  --action="reply=Reply" \
  --action="ignore=Ignore" &

notify-send "System Update" "Updates are available for your system." \
  --app-name="Software Updater" \
  --icon=system-software-update \
  --urgency=normal \
  --action="update=Update Now" \
  --action="later=Remind Later" &

notify-send "New Article" "Check out this interesting article!" \
  --app-name="News Reader" \
  --icon=internet-web-browser \
  --urgency=normal \
  --action="open=Open Browser" \
  --action="close=Close" &

notify-send "Incoming Call" "John Doe is calling..." \
  --app-name="Phone" \
  --icon=call-start \
  --urgency=critical \
  --action="accept=Accept" \
  --action="decline=Decline" \
  --action="message=Send Message" &

notify-send "Quick Math" "Need to do some calculations?" \
  --app-name="Calculator" \
  --icon=accessories-calculator \
  --urgency=low \
  --action="calc=Open Calculator" \
  --action="no=No Thanks" &

notify-send "Now Playing" "Awesome Song - Great Artist" \
  --app-name="Music Player" \
  --icon=media-playback-start \
  --urgency=normal \
  --action="pause=Pause" \
  --action="next=Next Track" \
  --action="playlist=Show Playlist" &

notify-send "Screenshot Taken" "Screenshot saved to ~/Pictures" \
  --app-name="Screenshot Tool" \
  --icon=camera-photo \
  --urgency=normal \
  --action="view=View Image" \
  --action="folder=Open Folder" \
  --action="delete=Delete" &

notify-send "Download Complete" "ubuntu-24.04.iso finished downloading." \
  --app-name="Downloads" \
  --icon=folder-download \
  --urgency=normal \
  --action="open=Open File" \
  --action="show=Show in Folder" &

notify-send "Low Battery" "Battery level is at 15%." \
  --app-name="Power Manager" \
  --icon=battery-caution \
  --urgency=critical \
  --action="settings=Power Settings" &

notify-send "Reminder" "Team standup in 5 minutes" \
  --app-name="Calendar" \
  --icon=x-office-calendar \
  --urgency=normal \
  --action="join=Join Meeting" \
  --action="snooze=Snooze" &

notify-send "Build Succeeded" "Project compiled with 0 errors, 3 warnings." \
  --app-name="IDE" \
  --icon=dialog-information \
  --urgency=low \
  --action="logs=View Logs" &

wait

echo "=== All $( echo 12 ) notifications fired! ==="