#!/bin/bash
# start with nohup ./clipsharemac.sh hostname & 
# hostname should be in .ssh/config
# on other side, run clipsharex.sh

# Configuration
SSH_SHORTCUT="${1:-}"
SYNC_INTERVAL=0.5

# Validate SSH shortcut if provided
if [[ -z "$SSH_SHORTCUT" ]]; then
    echo "Usage: $0 <ssh_config_shortcut>"
    echo "Running in local-only mode..."
    SSH_SHORTCUT=""
fi
sync_time=0
while sleep "$SYNC_INTERVAL"; do 
    # Dump current clipboard to temp file
    pbpaste >| ~/mclipout.tmp
    
    # Only update mclipout if content changed
    if ! cmp -s ~/mclipout ~/mclipout.tmp 2>/dev/null; then
        cp ~/mclipout.tmp ~/mclipout
    fi
    
    # If remote sync is enabled, rsync the clipboard files
    if [[ -n "$SSH_SHORTCUT" ]]; then
        # Sync local clipboard to remote
        rsync -avz --checksum ~/mclipout "$SSH_SHORTCUT:~/" 2>/dev/null
        
        # Sync remote X clipboard back to local
        rsync -avz --checksum "$SSH_SHORTCUT:~/xclipxout" ~/ 2>/dev/null
        
        # Determine which clipboard is newer and copy to clipxin
        if [[ -f ~/mclipout && -f ~/xclipxout ]]; then
            local_time=$(stat -f%m ~/mclipout 2>/dev/null || echo 0)
            remote_time=$(stat -f%m ~/xclipxout 2>/dev/null || echo 0)
            
            if (( local_time > remote_time && (local_time>sync_time || remote_time>sync_time) )); then
                sync_time=$local_time
                scp ~/mclipout "$SSH_SHORTCUT:~/clipxin" 2>/dev/null
            elif (( remote_time > local_time )); then
                sync_time=$remote_time
                # X clipboard is newer - copy locally to clipxin (will be read next iteration)
                cp ~/xclipxout ~/clipxin
            fi
        fi
    fi
    
    # Handle local clipboard input (if clipxin exists)
    if [[ -f ~/clipxin ]]; then
        pbcopy < ~/clipxin
        rm ~/clipxin
    fi
done

