using Azure.AI.OpenAI;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

string endpoint = "https://aoai-dev.openai.azure.us/";
SecretClient secretClient = new(new Uri("https://cmagvashared-kv.vault.usgovcloudapi.net/"), new DefaultAzureCredential());

KeyVaultSecret azureOpenAIAPISecret = await secretClient.GetSecretAsync("AOAIKey");
KeyVaultSecret azureSearchAPISecret = await secretClient.GetSecretAsync("AISearchKey");

string AIkey = azureOpenAIAPISecret.Value;
string Searchkey = azureSearchAPISecret.Value;

var client = new OpenAIClient( new Uri(endpoint), new Azure.AzureKeyCredential(AIkey));
var deploymentId = "dev-gpt";
var searchEndpoint = "https://search-dev.search.azure.us";
var searchIndexName = "azureblob-index";

var chatCompletionsOptions = new ChatCompletionsOptions()
{
    Messages =
    {
        new ChatRequestSystemMessage("Tell me the differences between Azure Machine Learning and Azure AI services."),
        new ChatRequestUserMessage("what name is on the Florida license?")
    },
    // The addition of AzureChatExtensionsOptions enables the use of Azure OpenAI capabilities that add to
    // the behavior of Chat Completions, here the "using your own data" feature to supplement the context
    // with information from an Azure AI Search resource with documents that have been indexed.
    AzureExtensionsOptions = new AzureChatExtensionsOptions()
    {
        Extensions =
        {
            new AzureSearchChatExtensionConfiguration()
            {
                SearchEndpoint = new Uri(searchEndpoint),
                IndexName = searchIndexName,
                Authentication = new OnYourDataApiKeyAuthenticationOptions(Searchkey),
                QueryType = AzureSearchQueryType.Semantic,
            },
        },
    },
    DeploymentName = deploymentId,
    MaxTokens = 800,
    Temperature = 0,
    

};
Azure.Response<ChatCompletions> response = await client.GetChatCompletionsAsync(chatCompletionsOptions);
    ChatResponseMessage message = response.Value.Choices[0].Message;

    // The final, data-informed response still appears in the ChatMessages as usual
    Console.WriteLine($"{message.Role}: {message.Content}");

    // Responses that used extensions will also have Context information to explain extension activity
    // and provide supplemental information like citations.
    Console.WriteLine($"Citations and other information:");

    foreach (AzureChatExtensionDataSourceResponseCitation citation in message.AzureExtensionsContext.Citations)
    {
        Console.WriteLine($"Citation: {citation.Content}");
    }
    Console.WriteLine($"Intent: {message.AzureExtensionsContext.Intent}");

