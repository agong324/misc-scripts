#!/usr/bin/env bash

# @author    Spas Z. Spasov <spas.z.spasov@gmail.com>
# @copyright 2021 Spas Z. Spasov
# @license   https://www.gnu.org/licenses/gpl-3.0.html GNU General Public License, version 3 (or later)

# Set the source backup directory
src_dir=("") #insert your source directory here

# Set the targer backup directory
tgt_dir="" #insert your target directory here for backup

# Exclude files matching PATTERN 
exclude+=("appdata/" "adminVM/" "docker.img" "jellyfin/" "Guest_Share/")
exclude+=(".adobe/" ".apport-ignore.xml" ".bash_history" ".cache/" ".compiz/" ".config/" ".cups/")
exclude+=(".dbus/" ".dmrc" ".gconf/" ".gimp-2.8/" ".gitkraken/" ".gksu.lock" ".gnome/" ".gnupg/" ".gtk-bookmarks" ".gtk-recordmydesktop")
exclude+=(".ICEauthority" ".lesshst" ".local/" ".~lock.script.code*" ".macromedia/" ".mozilla/" ".nano/" ".nv/" ".nvidia-settings-rc")
exclude+=(".pki/" "*.swp" ".sudo_as_admin_successful" ".thumbnails/" ".Trash-1000/")
exclude+=(".ViberPC/" "ViberDownloads/" ".vmware/" ".vscode" ".wget-hsts" ".wine/" ".Xauthority" ".xsession-errors*")

# Remove the backups older than 12 months
age=$(date +%F --date='12 months ago')
for i in "$tgt_dir"/*
do
    if [[ -d $i ]] && [[ ${age//-} -ge $(echo "$i" | sed -r 's/^.*([0-9]{4})-([0-9]{2})-([0-9]{2}).*$/\1\2\3/') ]] 2>/dev/null
    then
        echo "This backup will be deleted: $i"
        read -p "Are you sure you want to continue? (y/N/q to quit): " confirm
        if [[ "$confirm" == "q" || "$confirm" == "Q" ]]; then
                echo "Aborted."
                exit 1
        elif [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then 
                echo "Skipping: $i" 
                continue
        fi 
        rm -rf "$i"
        echo "Deleted: $i"
    fi
done

# Generate a list of source directories from the array
# 'eval' is essential to use a variable as command or option
src_dir=$(printf -- '"%s" ' "${src_dir[@]}")

# Generate a list with exclude options from the array
# --exclude=PATTERN :Exclude files matching PATTERN
exclude=$(printf -- "--exclude '%s' " "${exclude[@]}")

# Create the backup directory if doesn't exist
[[ ! -d $tgt_dir ]] && mkdir -p "$tgt_dir"

# current backup directory, e.g. "2017-04-29";
now=$(date +%F)

# previous backup directory
prev=$(ls "$tgt_dir" | grep -e '^....-..-..$' | tail -1);

# debug options and create $now directory
echo "Source directory is: $src_dir"
echo "Target directory is: $tgt_dir"
echo "Backup directory is: $tgt_dir/$now"
echo "Previous backup directory: $prev"
mkdir -p "$tgt_dir/$now" || { echo "Failed to create directory"; exit 1; }

make_backup() {
    if [[ -z $prev ]]; then
        # initial backup
        eval rsync -av --delete ${exclude} ${src_dir} "$tgt_dir/$now/"
    else
        # incremental backup
        eval rsync -av --delete --link-dest="$tgt_dir/$prev/" ${exclude} ${src_dir} "$tgt_dir/$now/"
    fi
}; make_backup > "${tgt_dir}/.backup.log" 2>&1

# Create statistics
echo -e "\n${now}\t$(du -hs "$tgt_dir/$now")\n" >> "${tgt_dir}/.backup.log"
df -h "$tgt_dir" >> "${tgt_dir}/.backup.log"
exit 0;
