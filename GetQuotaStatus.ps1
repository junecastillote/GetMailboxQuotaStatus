Function Get-QuotaStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [System.Object[]]
        $Mailbox
    )

    Begin {

    }
    Process {
        foreach ($item in $Mailbox) {
            # If the object is a mailbox object
            if ($item.PsObject.TypeNames[0] -like "*Microsoft.Exchange.Data.Directory.Management.Mailbox") {
                $currentMailbox = $item
            }

            # If the input is a string representation of the mailbox identity (ie. email, alias, and name)
            if ($item.PsObject.TypeNames[0] -eq "System.String") {
                try {
                    $currentMailbox = Get-Mailbox -Identity $item -ErrorAction Stop
                    # If the mailbox identifier is not unique (with more than 1 match), inform the operator and skip it.
                    if ($currentMailbox.Count -gt 1) {
                        "The mailbox identifier [$($item)] is not unique and will be skipped."
                    }
                }
                catch {
                    $_.Exception.Message | Out-Default
                }
            }

            if ($currentMailbox.Count -eq 1) {
                # Retrieve the IssueWarningQuota value
                $IssueWarningQuota = $(
                    if ($currentMailbox.IssueWarningQuota -ne 'Unlimited') {
                        [int64](($currentMailbox.IssueWarningQuota -Split " ")[2] -replace '\(', '' -replace ",", "")
                    }
                    else {
                        [int64]::MaxValue
                    }
                )

                # Retrieve the ProhibitSendQuota value
                $ProhibitSendQuota = $(
                    if ($currentMailbox.ProhibitSendQuota -ne 'Unlimited') {
                        [int64](($currentMailbox.ProhibitSendQuota -Split " ")[2] -replace '\(', '' -replace ",", "")
                    }
                    else {
                        [int64]::MaxValue
                    }
                )

                # Retrieve the ProhibitSendReceiveQuota value
                $ProhibitSendReceiveQuota = $(
                    if ($currentMailbox.ProhibitSendReceiveQuota -ne 'Unlimited') {
                        [int64](($currentMailbox.ProhibitSendReceiveQuota -Split " ")[2] -replace '\(', '' -replace ",", "")
                    }
                    else {
                        [int64]::MaxValue
                    }
                )

                # Retrieve the TotalItemSize value (mailbox size)
                $TotalItemSize = $(
                    if ($mailboxStatistics = Get-MailboxStatistics -Identity $currentMailbox.ExchangeGuid.ToString() -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
                        [int64](($mailboxStatistics.TotalItemSize -Split " ")[2] -replace '\(', '' -replace ",", "")
                    }
                    else {
                        0
                    }
                )

                # Classify the mailbox storage quota status (Normal, Warning, Send Disabled, Send/Receive Disabled)
                $storageLimitStatus = $(
                    if ($TotalItemSize -lt $IssueWarningQuota) { 'Normal' }
                    if ($TotalItemSize -ge $IssueWarningQuota -and $TotalItemSize -lt $ProhibitSendQuota) { 'Warning' }
                    if ($TotalItemSize -ge $ProhibitSendQuota -and $TotalItemSize -lt $ProhibitSendReceiveQuota) { 'Send Disabled' }
                    if ($TotalItemSize -ge $ProhibitSendReceiveQuota ) { 'Send/Receive Disabled' }
                )

                [PSCustomObject](
                    [ordered]@{
                        Mailbox     = $currentMailbox.DisplayName
                        Email       = $currentMailbox.PrimarySmtpAddress
                        "Size(MB)"  = [Math]::Round($TotalItemSize / 1MB, 2)
                        QuotaStatus = $storageLimitStatus
                    }
                )
            }
        }
    }
    End {

    }
}
