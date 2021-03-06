function Send-Email
{
    Param
    (
	[string]$recipientEmail = $(Throw "At least one recipient email is required!"), 
    [string]$subject = $(Throw "An email subject header is required!"), 
    [string]$body
    )

    Begin
    {
        $outlook = New-Object -comObject  Outlook.Application 
        $mail = $outlook.CreateItem(0) 
        $mail.Recipients.Add($recipientEmail) 
        $mail.Subject = $subject 
        $mail.Body = $body
        }

    Process
    {   
        $mail.Send() |Out-Null
        }

    End
    {
        Return $?
        }
}
$Signature = "`n`nJeffrey S. Patton`nAssistant Director of IT`nSchool of Engineering Computing Services University of Kansas`n1520 West 15th Street Lawrence, KS. 66045-7621`n(785) 864-5232"
$Subject = "Engineering Disk Migration"
$Body = "Dear User, `n`nYour account is one of a handful of user accounts that have not yet been migrated. The reason your particular account has not"
$Body += " been migrated is most likely due to the fact that your account is logged in to one or more desktop computers. This causes our"
$Body += " migration script to skip you and store your account name in a spreadsheet so we can come back to you later."
$Body += "`n`nIt would help us out considerably if you could log out of any computers you are connected to before you leave for the weekend. This will"
$Body += " allow our script to finish things up. As there are so few users left your account will most likely be migrated well before Saturday morning."
$Body += "`n`nThanks in advance for your cooperation, and have a wonderful weekend!"
$Body += $Signature
$LegacyProfile = Get-ADGroupMembers -UserGroup LegacyProfile -UserDomain "LDAP://dc=soecs,DC=ku,DC=edu"
foreach ($member in $LegacyProfile)
{
    If ((($member.cn).ToString()).Contains("S-1-5-21") -eq $true)
    {
        $Sid = ($member.cn).ToString()
        $ThisUser = ((Convert-SIDToUser -ObjectSID (Convert-ObjectSID -ObjectSID $Sid)).Value).Replace("HOME" +"\", $null)
        $Recipient = "$($ThisUser)@ku.edu"
        Send-Email -recipientEmail $Recipient -subject $Subject -body $Body
        }
    }