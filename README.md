# GetMailboxQuotaStatus
PowerShell function to get the quota status of an Exchange Mailbox

## Get-QuotaStatus Function Usage

### Mailbox Object as Input

```PowerShell
# Individual mailbox via pipeline input
Get-Mailbox <mailbox> | Get-QuotaStatus

# All Mailbox via pipeline input
Get-Mailbox -ResultSize Unlimited | Get-QuotaStatus

# Individual mailbox via parameter input
$mailbox = Get-Mailbox <mailbox>
Get-QuotaStatus -Mailbox $mailbox
```

### Mailbox String Identifier as Input

```PowerShell
# Email address, alias, ExchangeGUID as input via pipeline input
'email@address.tld','alias','1814be8d-8700-4da1-932e-b8241f8ba1a7' | Get-QuotaStatus

# Email address, alias, ExchangeGUID as input via parameter input
Get-QuotaStatus -Mailbox 'email@address.tld','alias','1814be8d-8700-4da1-932e-b8241f8ba1a7'
```

## Sample Output

![image](https://github.com/junecastillote/GetMailboxQuotaStatus/assets/15041242/12bb5fef-750f-4e23-ab8f-5d73f7a8276a)
