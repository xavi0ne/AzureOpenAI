using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using Azure.AI.OpenAI;
using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;


namespace aoaifunctest
{
    public static class OpenAIFunction1
    {
        private static readonly HttpClient httpClient = new HttpClient();

        [FunctionName("OpenAIFunction")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

      
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string prompt = data?.prompt;

            if (string.IsNullOrEmpty(prompt))
            {
                return new BadRequestObjectResult("Please pass a prompt in the request body");
            }

            string endpoint = "https://aoai-dev.openai.azure.us/";
            SecretClient secretClient = new(new Uri("https://cmagvashared-kv.vault.usgovcloudapi.net/"), new DefaultAzureCredential());

            KeyVaultSecret azureOpenAIAPISecret = await secretClient.GetSecretAsync("AOAIKey");
            string AIkey = azureOpenAIAPISecret.Value;
            var client = new OpenAIClient( new Uri(endpoint), new Azure.AzureKeyCredential(AIkey));
            var deploymentId = "dev-gpt";

            //string apiKey = Environment.GetEnvironmentVariable("apiKey");
            //string endpoint = Environment.GetEnvironmentVariable("aoaiEndpoint");
            //string deploymentModel = "dev-gpt";
            string apiUrl = $"{endpoint}/openai/deployments/{deploymentModel}/completions?api-version=2023-10-01-preview";
            
            var chatCompletionsOptions = new ChatCompletionsOptions()
            {
                Messages =
                {
                    new ChatRequestSystemMessage("You are an assistant that provides information"),
                    new ChatRequestUserMessage(prompt)
                },
                    DeploymentName = deploymentId,
                    MaxTokens = 800,
                    Temperature = 0,
                    prompt = ChatRequestUserMessage
            };

            //var requestPayload = new
            //{
            //    prompt = prompt,
            //    max_tokens = 800,
            //    temperature = 0.2,
            //};

            var requestContent = new StringContent(JsonConvert.SerializeObject(chatCompletionsOptions), Encoding.UTF8, "application/json");

            httpClient.DefaultRequestHeaders.Clear();
            httpClient.DefaultRequestHeaders.Add("api-key", AIkey);

            HttpResponseMessage response = await httpClient.PostAsync(apiUrl, requestContent);
            string responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                return new BadRequestObjectResult($"Error calling OpenAI API: {responseContent}");
            }
            return new OkObjectResult(responseContent);
        }    
        
    }
}
