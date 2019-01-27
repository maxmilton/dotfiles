function up_gce -d 'Update Google Cloud SDK'
  if type -q gcloud
    yes | gcloud components update
  else
    echo "Google Cloud SDK not installed"
  end
end
