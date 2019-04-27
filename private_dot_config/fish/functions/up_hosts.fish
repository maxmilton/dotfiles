function up_hosts -d 'Update dnsmasq blacklist hosts file'
  if type --quiet dnsmasq
    if systemctl is-enabled dnsmasq.service 2>/dev/null
      set --local URL https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts
      set --local TEMP_FILE /tmp/hosts
      set --local FILE /etc/dnsmasq.d/hosts

      # clean up files from last run
      rm -f "$TEMP_FILE" "$TEMP_FILE"-sorted

      # download latest version of hosts file
      curl -fSL "$URL" -o "$TEMP_FILE"

      # find line number of end of top comments
      set --local DIV '# ==============================================================='
      set --local end_comments (grep -n "$DIV" "$TEMP_FILE" | cut -f1 -d:)

      # find line number of end of custom local host entries
      set --local CUST_HOSTS '# End of custom host records.'
      set --local end_cust_hosts (grep -n "$CUST_HOSTS" "$TEMP_FILE" | cut -f1 -d:)

      # add header comments
      head -n (math "$end_comments - 1") "$TEMP_FILE" > "$TEMP_FILE"-sorted

      sed -i \
        # remove custom local host entries
        -e "$end_comments,$end_cust_hosts d" \
        # remove comment lines
        -e 's/#.*$//' \
        # remove empty lines
        -e '/^[[:space:]]*$/d' \
        # remove broken domains (otherwise dnsmasq won't start)
        -e '/^0.0.0.0 -/d' \
        -e '/--/d' \
        "$TEMP_FILE"

      # add sorted list
      sort -f -u "$TEMP_FILE" >> "$TEMP_FILE"-sorted

      # ceate backup of previous file
      sudo rm -f "$FILE".bak
      sudo mv "$FILE" "$FILE".bak

      sudo mv "$TEMP_FILE"-sorted "$FILE"

      # restart dnsmasq
      sudo systemctl restart dnsmasq.service
      sleep 3
      sudo systemctl status dnsmasq.service
    else
      echo "dnsmasq.service systemd unit not enabled, aborting ad block hosts update."
    end
  else
    echo "dnsmasq command not found, aborting ad block hosts update."
  end
end
