provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

# resource "yandex_kms_symmetric_key" "key-a" {
#   name              = "teraform-state-symetric-key"
#   description       = "terraform state symetric key"
#   default_algorithm = "AES_256"
#   rotation_period   = "8760h"
# }

 resource "yandex_storage_bucket" "terraform-state-storage" {
   bucket        = var.bucket_name
   access_key    = var.storage_key
   secret_key    = var.storage_secret
   force_destroy = "true"

  #  versioning {
  #    enabled = true
  #  }

  #   server_side_encryption_configuration {
  #     rule {
  #       apply_server_side_encryption_by_default {
  #         kms_master_key_id = yandex_kms_symmetric_key.key-a.id
  #         sse_algorithm     = "aws:kms"
  #       }
  #     }
  #   }

  #   depends_on = [
  #       yandex_kms_symmetric_key.key-a
  #   ]
}
