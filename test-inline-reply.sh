#!/usr/bin/env nix-shell
#!nix-shell -i sh -p glib

echo "=== Inline Reply Notification Tests ==="
echo "Type in the reply field and hit Enter or click Send!"
echo ""

# Test 1: Basic inline reply
echo "Test 1: Basic inline reply notification"
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "Messenger" 0 "mail-unread" "New Message from Alice" "Hey, are you free for lunch today?" \
  '["inline-reply", "Reply"]' \
  '{"inline-reply-placeholder": <"Type your reply...">}' \
  5000

sleep 3

# Test 2: Inline reply with custom placeholder
echo "Test 2: Inline reply with custom placeholder"
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "Chat App" 0 "user-available" "Bob sent a photo" "Check out this sunset I captured!" \
  '["inline-reply", "Quick Reply", "view", "View Photo"]' \
  '{"inline-reply-placeholder": <"Say something nice...">}' \
  10000

sleep 3

# Test 3: Inline reply with multiple actions
echo "Test 3: Inline reply with actions"
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "Email" 0 "mail-message-new" "New Email" "Subject: Meeting Tomorrow\nFrom: boss@company.com\n\nPlease confirm your attendance." \
  '["inline-reply", "Reply", "archive", "Archive", "delete", "Delete"]' \
  '{"inline-reply-placeholder": <"Write a quick reply...">}' \
  15000

sleep 3

# Test 4: Inline reply with urgency
echo "Test 4: Urgent inline reply"
gdbus call --session \
  --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "Signal" 0 "dialog-warning" "Urgent: Team Group" "The server is down! Can someone check?" \
  '["inline-reply", "Reply"]' \
  '{"inline-reply-placeholder": <"Respond urgently...">, "urgency": <byte 2>}' \
  20000

echo ""
echo "=== All inline reply tests sent! ==="