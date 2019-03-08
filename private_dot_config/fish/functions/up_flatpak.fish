function up_flatpak -d 'Update flatpak packages'
  if type --quiet flatpak
    # flatpak update --noninteractive --assumeyes
    flatpak update
    flatpak list
  end
end
