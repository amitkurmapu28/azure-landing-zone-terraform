# Checkov Exceptions — Storage

## Exception: CKV_AZURE_206

- **Control:** Ensure that Storage Accounts use replication
- **Affected resource:** `azurerm_storage_account.landing_zone`
- **Configuration:** `account_replication_type = "ZRS"`
- **Status:** Proposed — pending review
- **Scope:** Azure Landing Zone learning environment

### Rationale

ZRS was intentionally selected for this environment to provide
zone-level redundancy in a supported Azure region.

Checkov 3.3.30 expects one of the following values for CKV_AZURE_206:
GRS, RAGRS, GZRS, or RAGZRS. ZRS does not satisfy this specific
geo-redundancy control.

### Risk and limitations

ZRS does not provide replication to a secondary Azure region.
A regional outage may therefore affect availability.

### Review conditions

Review this exception before production use, if disaster recovery
requirements change, or if the required recovery objectives change.

### Approval

Do not treat this proposed exception as production-approved.
Do not change the deployed infrastructure as part of this review.
