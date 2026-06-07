resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.service_account_id
}

resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  default_algorithm = "AES_256"
}

resource "yandex_kms_symmetric_key_iam_member" "key_access" {
  symmetric_key_id = yandex_kms_symmetric_key.bucket_key.id
  role             = "kms.keys.encrypterDecrypter"
  member           = "serviceAccount:${var.service_account_id}"
}

resource "yandex_storage_bucket" "my_bucket" {
  bucket = "mvmeles1-test.ru"
  #   access_key = var.access_key
  #   secret_key = var.secret_key
  default_storage_class = "COLD"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  anonymous_access_flags {
    read = true
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