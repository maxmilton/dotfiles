function pp-hosts -d 'Update ad blocking hosts file'
  if type -q dnsmasq
    set -l URL https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts
    set -l TEMP_FILE /tmp/hosts
    set -l FILE /etc/dnsmasq.d/hosts

    rm -f "$TEMP_FILE"
    curl -fSL "$URL" -o "$TEMP_FILE"

    # find which line is the end of custom local host entries
    set -l line_number (grep -n '# End of custom host records.' "$TEMP_FILE" | cut -f1 -d:)

    # comment out custom local host entries
    sed -i "1,$line_number s/^/# /" "$TEMP_FILE"

    sudo rm -f "$FILE".bak
    sudo mv "$FILE" "$FILE".bak
    sudo mv "$TEMP_FILE" "$FILE"
    sudo systemctl restart dnsmasq.service
    sleep 2
    sudo systemctl status dnsmasq.service
  end
end
