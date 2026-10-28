# Checkov Exceptions — Virtual Machines

## Exception: CKV_AZURE_50

- **Control:** Ensure Virtual Machine Extensions are not Installed
- **Affected resource:** `azurerm_windows_virtual_machine.lab`
- **Status:** Proposed — pending security review
- **Scope:** Azure Monitor Agent Windows monitoring lab

### Rationale

The virtual machine requires the Azure Monitor Agent (AMA) extension to collect guest operating-system telemetry and support Azure Monitor data collection.

The Checkov control evaluates the `allow_extension_operations` property and expects it to be `false`. Disabling extension operations may conflict with the required monitoring-agent deployment or management workflow.

### Risk and compensating controls

- Retain only required VM extensions.
- Review extension publishers, names, versions, and permissions.
- Keep the VM and agent configuration managed through approved Terraform changes.
- Review this exception if the monitoring architecture changes.

### Approval

This exception is proposed and is not production-approved. Confirm compatibility and obtain the required security approval before suppressing the finding or deploying changes.