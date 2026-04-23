using Microsoft.Data.SqlClient;
using Azure.Identity;
using Dapper;


var builder = WebApplication.CreateBuilder(args);

// Add this before builder.Build()
builder.Services.AddCors(options => {
    options.AddDefaultPolicy(policy => {
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
    });
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

// Enable the middleware (MUST be before MapGet/Controllers)
app.UseCors(); 

// Connection string for Private Endpoint
// NOTE: Use the private FQDN (e.g. yourserver.database.windows.net) 
// The AKS DNS will resolve this to your Private Endpoint's internal IP.
// This string is safe for source control as it has no passwords
string connectionString = "Server=tcp:degreed-sql-server.database.windows.net,1433;Initial Catalog=degreed-data;Encrypt=True;Authentication=Active Directory Default;";


app.MapGet("/quote", async () =>
{
    // DefaultAzureCredential automatically handles:
    // 1. Local: Your VS Code/Azure CLI login
    // 2. AKS: The Workload Identity assigned to the pod
    using var connection = new SqlConnection(connectionString);
    
    try {
        // Use QueryFirstOrDefault to fetch the random row
        var quote = await connection.QueryFirstOrDefaultAsync<Quote>("SELECT TOP 1 QuoteText, Author FROM Quotes ORDER BY NEWID()");
        return quote is not null ? Results.Ok(quote) : Results.NotFound();
    }
    catch (Exception ex) {
        Console.WriteLine($"DB ERROR: {ex.Message}");
        return Results.Problem(ex.Message);
    }
});

app.Run();

// Data model for the Quotes table
record Quote(string QuoteText, string Author);