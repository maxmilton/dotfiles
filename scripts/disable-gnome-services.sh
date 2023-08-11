#!/bin/sh -eu

systemctl --user mask org.gnome.SettingsDaemon.A11ySettings.service
systemctl --user mask org.gnome.SettingsDaemon.PrintNotifications.service
systemctl --user mask org.gnome.SettingsDaemon.ScreensaverProxy.service
systemctl --user mask org.gnome.SettingsDaemon.Sharing.service
systemctl --user mask org.gnome.SettingsDaemon.Smartcard.service
systemctl --user mask org.gnome.SettingsDaemon.Wacom.service
systemctl --user mask org.gnome.SettingsDaemon.Wwan.service

#sudo systemctl mask bolt
sudo systemctl mask geoclue.service

# gsettings set org.gnome.system.location enabled false
