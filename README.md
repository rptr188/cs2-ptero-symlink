# cs2-ptero-symlink
This bash script has for a task to periodically check for updates (via crontab on host machine), and in case if CS2 update occurs, automatically shuts down servers, updates base mount, symlinks and binary files and turns servers on.
By enabling this possibility, every new server installation will copy only binary files, taking ~400 MB of disk space.


Prerequisites:

jq package

Wings + Pterodactyl combination

1zc-Pterodactyl egg

