var builder = WebApplication.CreateBuilder(args);

// Register HttpClient with the Kubernetes Service name as the BaseAddress
builder.Services.AddHttpClient("BackendClient", client =>
{
    // "backend-service" is the DNS name defined in your aks-deploy.yaml
    // Look for an environment variable; if not found, use localhost for VS Code testing
    var backendUrl = builder.Configuration["BACKEND_URL"] ?? "http://localhost:5000";
    client.BaseAddress = new Uri(backendUrl);
});


var app = builder.Build();

// This endpoint calls the backend to return a random quote from the database, demonstrating secure database access via a Private Endpoint and Azure AD authentication
app.MapGet("/", async (IHttpClientFactory clientFactory) =>
{
    // Create the client using the name registered above
    var client = clientFactory.CreateClient("BackendClient");
    try 
    {
        var result = await client.GetFromJsonAsync<object>("quote");
        return Results.Ok(result);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"DB ERROR: {ex.Message}");
        return Results.Problem(ex.ToString());
    }
});

app.MapGet("/healthz", () => Results.Ok("I am Healthy"));
app.Run();
