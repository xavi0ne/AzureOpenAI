# Azure Open AI using PowerShell

## How to securely call Azure Open AI chat API and actively interact with the chat-gpt model using PowerShell

### Pre-requisites

+ Azure PowerShell 5.7 or later installed
+ An Azure Subscription
+ An existing Azure Open AI service with chat-gpt deployment model
+ An existing Azure Key Vault with the Azure Open AI API Key added as a secret.

### Add Parameter Values to the script. 

Before running the 'AzureOpenAIChatCompletion.ps1' script, ensure to collect the parameter values based on pre-requisites to include: 

+ Azure Key Vault Name
+ Azure Key Vault Secret for the Azure Open AI API Key
+ Azure Open AI Service Name
+ Azure Open AI deployment model name

You can also adjust the Azure Open AI parameters to fine-tune model performance. These parameters are temperature, top_p, and max tokens. The temperature parameter allows you to fine-tune model's creativity level from 0 - 2, where the higher the number the increased level of creativity. Should you desire a response more determined and logical, ensure a lower temperature is used for the model. Top_p also allows fine-tuning of model for randomness. However, ensure only one or the other are adjusted and not both at a given time. 

The chat-gpt model performs using tokens. One token is equivalent to 4 char's. Should you desire to provide a prompt that is higher in length, ensure the max_token is set to a higher amount. Adjusting max_token between 300-500 will allow the model to provide complete responses without the chance of cutting off response due to limitation. 

### Run the script. 

The script will prompt for you to connect to your Azure subscription, where a browser will prompt you for your credentials. Upon succesful authentication, you will receive a prompt to enter your message and begin interaction with the chat-gpt model. After the model's response, you will be prompted if you wish to continue conversation. Responding 'yes' will allow continuous interaction and response, while responding 'no' will result in exiting the chat-gpt conversation. 
