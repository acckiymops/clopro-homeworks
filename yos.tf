resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.service_account_id
}

resource "yandex_storage_bucket" "my_bucket" {
  bucket = "mvmeles1-bucket"
  #   access_key = var.access_key
  #   secret_key = var.secret_key
  default_storage_class = "COLD"

  anonymous_access_flags {
    read = false
    list = false
  }
}

resource "yandex_storage_bucket_grant" "my_bucket_grant" {
  bucket = "mvmeles1-bucket"
  grant {
    id          = var.service_account_id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }
}

resource "yandex_storage_object" "netology_logo" {
  bucket = yandex_storage_bucket.my_bucket.id
  key    = "net-logo.jpg"
  source = "./netology.jpg"
}