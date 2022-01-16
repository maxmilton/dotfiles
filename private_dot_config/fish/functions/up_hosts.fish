function up_hosts --description 'Update dnsmasq blacklist hosts file'
  if type --query dnsmasq
    if systemctl is-enabled dnsmasq.service 2>/dev/null
      set --local url https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts
      set --local temp_file /tmp/hosts
      set --local hosts_file /etc/dnsmasq.d/hosts.conf

      # clean up files from last run
      rm -f "$temp_file" "$temp_file"-sorted

      # download latest version of hosts file
      curl -fSL "$url" -o "$temp_file"

      # find line number of end of top comments
      set --local div '# ==============================================================='
      set --local end_comments (grep -n "$div" "$temp_file" | cut -f1 -d:)

      # find line number of end of custom local host entries
      set --local cust_hosts_marker '# End of custom host records.'
      set --local end_cust_hosts (grep -n "$cust_hosts_marker" "$temp_file" | cut -f1 -d:)

      # add header comments
      head -n (math "$end_comments - 1") "$temp_file" > "$temp_file"-sorted

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
        # replace hosts file syntax with dnsmasq syntax
        -e 's/^0\.0\.0\.0 \(.*\)$/address=\/\1\//g' \
        "$temp_file"

      # add sorted list
      sort -f -u "$temp_file" >> "$temp_file"-sorted

      # ceate backup of previous file
      sudo rm -f "$hosts_file".bak
      sudo mv "$hosts_file" "$hosts_file".bak

      sudo mv "$temp_file"-sorted "$hosts_file"

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
