using System.Text;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authorization;
using Opalsnz.Accounting.Db;
using Opalsnz.Accounting.Model.Auth;
using Opalsnz.Accounting.Service.Assets;
using Opalsnz.Accounting.Service.Auth;
using Opalsnz.Accounting.Service.BusinessPurchases;
using Opalsnz.Accounting.Service.HomeOfficeExpenses;
using Opalsnz.Accounting.Service.Income;
using Opalsnz.Accounting.Service.Reports;
using Opalsnz.Accounting.Service.TradingStock;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Env vars override appsettings - lets Production supply secrets without committing them.
builder.Configuration.AddEnvironmentVariables();

builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .WriteTo.Console());

// Add services to the container.

builder.Services.AddControllers()
    .AddJsonOptions(options => options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var corsPolicy = "AccountingAppOrigin";
builder.Services.AddCors(options =>
{
    options.AddPolicy(corsPolicy, policy =>
    {
        var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
        policy.WithOrigins(allowedOrigins).AllowAnyHeader().AllowAnyMethod();
    });
});

builder.Services.AddDbContext<AccountingContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("ConnectionStrings:DefaultConnection not configured");
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));
});

builder.Services.AddHealthChecks().AddDbContextCheck<AccountingContext>();

builder.Services.Configure<JwtOptions>(builder.Configuration.GetSection(JwtOptions.SectionName));
builder.Services.Configure<SingleUserOptions>(builder.Configuration.GetSection(SingleUserOptions.SectionName));

builder.Services.AddSingleton<IPasswordHasher, PasswordHasher>();
builder.Services.AddSingleton<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IAuthService, AuthService>();

builder.Services.AddScoped<IIncomeService, IncomeService>();
builder.Services.AddScoped<IExpenseCategoryService, ExpenseCategoryService>();
builder.Services.AddScoped<IHomeOfficeExpenseService, HomeOfficeExpenseService>();
builder.Services.AddScoped<IBusinessPurchaseService, BusinessPurchaseService>();
builder.Services.AddScoped<IAssetService, AssetService>();
builder.Services.AddScoped<IAssetDepreciationService, AssetDepreciationService>();
builder.Services.AddScoped<ITradingStockService, TradingStockService>();
builder.Services.AddScoped<IHistoricalStockPurchaseService, HistoricalStockPurchaseService>();
builder.Services.AddScoped<IReportService, ReportService>();

var jwtOptions = builder.Configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>()
    ?? throw new InvalidOperationException("Jwt configuration section is missing");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtOptions.Audience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.SigningKey)),
            ValidateLifetime = true,
        };
    });

// Secure by default - every endpoint requires auth unless explicitly marked [AllowAnonymous].
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseCors(corsPolicy);

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
// Health checks (container/orchestrator probes) must stay anonymous despite the fallback auth policy.
app.MapHealthChecks("/health").AllowAnonymous();

app.Run();
