#!/bin/sh

echo "=== Notification Action Tests ==="
echo "Click the actions in the notifications to see them work!"
echo ""

# Test 1: Open file manager
echo "Test 1: File Manager notification"
ACTION=$(notify-send "File Manager" "Click to open Dolphin file manager" \
  --app-name="Files" \
  --icon=system-file-manager \
  --urgency=normal \
  --action="open=Open Dolphin" \
  --action="cancel=Cancel")

if [ "$ACTION" = "open" ]; then
  echo "Opening Dolphin..."
  dolphin &
elif [ "$ACTION" = "cancel" ]; then
  echo "Cancelled"
fi

sleep 1

# Test 2: Text editor
echo "Test 2: Message notification"
ACTION=$(notify-send "New Message" "You have a new message. Click to reply." \
  --app-name="Messenger" \
  --icon=mail-unread \
  --urgency=normal \
  --action="reply=Reply in Kate" \
  --action="ignore=Ignore")

if [ "$ACTION" = "reply" ]; then
  echo "Opening Kate..."
  kate &
elif [ "$ACTION" = "ignore" ]; then
  echo "Message ignored"
fi

sleep 1

# Test 3: Terminal command
echo "Test 3: System update notification"
ACTION=$(notify-send "System Update" "Updates are available for your system." \
  --app-name="Software Updater" \
  --icon=system-software-update \
  --urgency=normal \
  --action="update=Update Now" \
  --action="later=Remind Later")

if [ "$ACTION" = "update" ]; then
  echo "Opening terminal for update..."
  konsole -e sh -c "echo 'This would run system updates...'; echo 'Press Enter to close'; read" &
elif [ "$ACTION" = "later" ]; then
  echo "Update postponed"
fi

sleep 1

# Test 4: Web browser
echo "Test 4: Notification with URL"
ACTION=$(notify-send "New Article" "Check out this interesting article!" \
  --app-name="News Reader" \
  --icon=internet-web-browser \
  --urgency=normal \
  --action="open=Open Browser" \
  --action="close=Close")

if [ "$ACTION" = "open" ]; then
  echo "Opening browser..."
  xdg-open "https://quickshell.org" &
elif [ "$ACTION" = "close" ]; then
  echo "Notification closed"
fi

sleep 1

# Test 5: Multiple actions
echo "Test 5: Call notification with multiple actions"
ACTION=$(notify-send "Incoming Call" "John Doe is calling..." \
  --app-name="Phone" \
  --icon=call-start \
  --urgency=critical \
  --action="accept=Accept" \
  --action="decline=Decline" \
  --action="message=Send Message")

if [ "$ACTION" = "accept" ]; then
  echo "Call accepted!"
  notify-send "Call Accepted" "Connected to John Doe" --icon=call-start
elif [ "$ACTION" = "decline" ]; then
  echo "Call declined"
  notify-send "Call Declined" "Missed call from John Doe" --icon=call-stop
elif [ "$ACTION" = "message" ]; then
  echo "Opening messaging..."
  kate &
fi

sleep 1

# Test 6: Calculator
echo "Test 6: Calculator notification"
ACTION=$(notify-send "Quick Math" "Need to do some calculations?" \
  --app-name="Calculator" \
  --icon=accessories-calculator \
  --urgency=low \
  --action="calc=Open Calculator" \
  --action="no=No Thanks")

if [ "$ACTION" = "calc" ]; then
  echo "Opening calculator..."
  kcalc &
elif [ "$ACTION" = "no" ]; then
  echo "Calculator not needed"
fi

sleep 1

# Test 7: Music player
echo "Test 7: Music player notification"
ACTION=$(notify-send "Now Playing" "Awesome Song - Great Artist" \
  --app-name="Music Player" \
  --icon=media-playback-start \
  --urgency=normal \
  --hint=int:resident:1 \
  --action="pause=Pause" \
  --action="next=Next Track" \
  --action="playlist=Show Playlist")

if [ "$ACTION" = "pause" ]; then
  echo "Music paused"
  notify-send "Music Paused" "Playback paused" --icon=media-playback-pause
elif [ "$ACTION" = "next" ]; then
  echo "Next track"
  notify-send "Next Track" "Another Song - Different Artist" --icon=media-skip-forward
elif [ "$ACTION" = "playlist" ]; then
  echo "Opening playlist..."
  dolphin ~/Music &
fi

sleep 1

# Test 8: Screenshot tool
echo "Test 8: Screenshot notification"
ACTION=$(notify-send "Screenshot Taken" "Screenshot saved to ~/Pictures" \
  --app-name="Screenshot Tool" \
  --icon=camera-photo \
  --urgency=normal \
  --action="view=View Image" \
  --action="folder=Open Folder" \
  --action="delete=Delete")

if [ "$ACTION" = "view" ]; then
  echo "Opening image viewer..."
  gwenview ~/Pictures &
elif [ "$ACTION" = "folder" ]; then
  echo "Opening Pictures folder..."
  dolphin ~/Pictures &
elif [ "$ACTION" = "delete" ]; then
  echo "Screenshot deleted"
  notify-send "Deleted" "Screenshot removed" --icon=edit-delete
fi

echo ""
echo "=== All tests completed! ==="
echo "Actions were: click notification buttons to trigger programs"