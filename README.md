# GetMailboxQuotaStatus
PowerShell function to get the quota status of an Exchange Mailbox

## Get-QuotaStatus Function Usage

### Mailbox object as input

```PowerShell
# Individual mailbox
Get-Mailbox <mailbox id> | Get-QuotaStatus

# All Mailbox
Get-Mailbox -ResultSize Unlimited | Get-QuotaStatus
```
