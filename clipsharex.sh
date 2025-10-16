#!/bin/bash
#start with nohup ./clipsharemac.sh hostname & 
SYNC_INTERVAL=0.5

while sleep "$SYNC_INTERVAL"; do 
    # Dump current X clipboard to temp file
    xclip -o >| ~/xclipxout.tmp
    
    # Only update xclipxout if content changed
    if ! cmp -s ~/xclipxout ~/xclipxout.tmp 2>/dev/null; then
        cp ~/xclipxout.tmp ~/xclipxout
    fi
    # Handle clipboard input (if clipxin exists, written by remote Mac)
    if [[ -f ~/clipxin ]]; then
        xclip -sel c < ~/clipxin
        rm ~/clipxin
    fi
done
clipshare