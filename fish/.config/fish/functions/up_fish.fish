function up_fish -d 'Update fish shell'
  fisher self-update
  fisher ls | fisher add
end
