# Checkov Detection Notes — Storage

## CKV_AZURE_33 — Queue service logging

- **Scanner version:** Checkov 3.3.30
- **Affected resource:** `azurerm_storage_account.landing_zone`
- **Status:** Detection limitation under investigation
- **Finding:** Failed — intentionally remains visible

### Configuration

Queue service logging is configured through the standalone
`azurerm_storage_account_queue_properties.landing_zone` resource.
Read, write, and delete logging are enabled, with a seven-day
retention period.

### Detection limitation

The installed Checkov 3.3.30 implementation of CKV_AZURE_33
inspects the `queue_properties.logging` block inside
`azurerm_storage_account`. It does not inspect the standalone
`azurerm_storage_account_queue_properties` resource.

Consequently, the scanner reports a failure even though the
Terraform configuration declares queue logging in the standalone
resource. This finding must not be treated as proof that logging
is active in Azure.

### Follow-up

- Keep the finding visible in Checkov results.
- Verify the actual logging configuration through an approved
  Terraform plan and Azure configuration review before deployment.
- Reassess this detection when Checkov support changes.
- Do not restore the deprecated nested block solely to satisfy
  the scanner without reviewing provider compatibility.
- Do not suppress this finding as part of this change.
