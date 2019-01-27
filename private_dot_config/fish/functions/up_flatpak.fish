function up_flatpak -d 'Update flatpak packages'
  flatpak update --noninteractive --assumeyes
  flatpak list
end
