function up_gce -d 'Update Google Cloud SDK'
  yes | gcloud components update
end
