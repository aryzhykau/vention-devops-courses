using System;
using System.Collections.Generic;
using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Добавляем сервисы
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Настраиваем HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();

// Определяем маршруты
app.MapGet("/", () => "Привет от C# приложения в Docker!");

app.MapGet("/api/info", () => 
{
    var info = new Dictionary<string, object>
    {
        ["hostname"] = Dns.GetHostName(),
        ["framework"] = System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription,
        ["os"] = System.Runtime.InteropServices.RuntimeInformation.OSDescription,
        ["processors"] = Environment.ProcessorCount,
        ["machineId"] = Environment.MachineName,
        ["timestamp"] = DateTime.UtcNow,
    };
    
    return Results.Json(info);
});

app.MapGet("/health", () => 
{
    var status = new Dictionary<string, string>
    {
        ["status"] = "Healthy",
        ["time"] = DateTime.UtcNow.ToString()
    };
    
    return Results.Json(status);
});

// Запускаем сервер
app.Run(); 