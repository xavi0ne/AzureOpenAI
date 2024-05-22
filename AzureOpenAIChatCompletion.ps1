Connect-AzAccount -environment Azureusgovernment

$keyVaultName = "<keyVaultName>"
$apiSecretName = "<AOAIKey>"
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName  -Name $apiSecretName
$ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
try {
  $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
} finally {
  [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
}
Write-Output $secretValueText


$header = [ordered]@{ 
    "api-key" = $secretValueText
}

$apiversion = "<AzureOpenAIapiversion>"
$deploymentName = "<deploymentName>"
$resourceName = "<AzureOpenAIName>"
$maxTokens = 800
$temperature = 0.2
$top_p = 0.5

do {
    $userMessage = Read-Host -Prompt "Enter your message"

    $messages = @()
    $messages += @{
        role = 'system'
        content = 'You are a helpful assistant.'
    }
    $messages += @{
        role = 'user'
        content = $userMessage
    }

    $body = [ordered]@{
        messages = $messages
        max_tokens = $maxTokens
        temperature = $temperature
        top_p = $top_p
    } | ConvertTo-Json

    $uri = "https://$resourceName.openai.azure.us/openai/deployments/$deploymentName/chat/completions?api-version=$apiversion"

    $response = Invoke-RestMethod -Uri $uri -Headers $header -Body $body -Method Post -ContentType 'application/json'

    $response.choices[0].message.content
     
    $continue = Read-host -Prompt "Do you want to continue the conversation? (yes/no)"
} 
until ($continue -ne "no" -ne "No")
