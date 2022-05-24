function up_flatpak --description 'Update flatpak packages'
  if type --query flatpak
    flatpak update --noninteractive --assumeyes
    flatpak list
  end
end
