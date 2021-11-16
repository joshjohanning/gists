##############################################################
# Delete all notification subscriptions for a specific org
##############################################################

# Description: You may have to run this multiple times - but it's better than:
# a) unwatching all repos or
# b) clicking thru yourself to unwatch
#
# See watched repos here: https://github.com/watching

# Example usage: 
# ./fix-github-notifications.ps1 -pat "<github-pat-given-notifications-and-repo-access>" -org "github"

[CmdletBinding()]
param (
    [parameter (Mandatory = $true)][string]$pat,
    [parameter (Mandatory = $true)][string]$org
)

# Set up API Header
$AuthenticationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)")) }

####### Script #######

$perPage = 100
$prePage = -1
$currentPage = 0


$orgSearch = "$org/*"
$pageCount = 1

while (($pageCount -eq 1) -or ($results -ge 0)) {
    $notifications = Invoke-RestMethod -Uri "https://api.github.com/user/subscriptions?per_page=$perPage&page=$pageCount" -Method GET -Headers $AuthenticationHeader -ContentType 'application/json'

    $currentPage = $notifications.count
    write-host "-- $currentPage notifications on page $pageCount --"

    # checking to see if the previous page results = current page results...this would indicate we can stop
    # we can't just do $results = $perPage b/c sometime it doesn't get the full amount that it should with $perPage ?
    if($prePage -eq $currentPage) {
        # checking to see if our previous page results is = the perPage setting - if so, we should continue
        if($currentPage -eq $perPage) {
            # continue
        }
        else {
            write-host "seems like no more notifications to retrieve - exiting"
            exit
        }
    }

    foreach($notification in $notifications) {
    if($notification.full_name -like $orgSearch) {
        write-host "Deleting notification policy: $($notification.full_name) ..."
        Invoke-RestMethod -Uri "https://api.github.com/repos/$org/$($notification.name)/subscription" -Method DELETE -Headers $AuthenticationHeader -ContentType 'application/json'
        }
    }

    $results = $notifications.count
    $pageCount += 1
    $prePage = $results
}
