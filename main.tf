provider "google" {
  credentials = file("YOUR_CREDENTIAL_FILE.json") # Replace with your credential file
  project     = "YOUR_PROJECT_ID"                 # Replace with your project ID
}

resource "google_storage_bucket" "bucket" {
  name          = "YOUR_BUCKET_NAME"              # Replace with your bucket name
  location      = "US-CENTRAL1"                   # Adjust the bucket location as needed
  force_destroy = true                            # Allows the bucket to be destroyed
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "YOUR_DATASET_ID" # Replace with your dataset ID
  location                    = "US"               # Adjust the dataset location as needed
  delete_contents_on_destroy = true                # Allows the dataset contents to be deleted when the resource is destroyed
  # Add other variables as needed for this resource
}

resource "null_resource" "main_pipeline" {
  provisioner "local-exec" {
    command = "python3 main_pipeline.py"           # Executes the main pipeline script
  }
  depends_on = [google_bigquery_dataset.dataset]  # Ensures the dataset is created before the pipeline is run
}

resource "null_resource" "stop_dataflow_job_on_destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud dataflow jobs cancel $(head -n 1 job_info.txt) --region=$(tail -n 1 job_info.txt)"
    # Cancels the Dataflow job when the resource is destroyed, utilizing the job info saved in the `job_info.txt` file
  }
  depends_on = [null_resource.main_pipeline]       # Ensures the main pipeline runs before this resource
}