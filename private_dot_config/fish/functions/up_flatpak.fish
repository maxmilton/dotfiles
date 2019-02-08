function up_flatpak -d 'Update flatpak packages'
  if type --quiet yarn
    flatpak update --noninteractive --assumeyes
    flatpak list
  end
end
