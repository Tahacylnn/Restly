using System;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Serilog;
using System.IO;

var builder = Host.CreateApplicationBuilder(args);
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);

// Setup Serilog to file
var logPath = builder.Configuration.GetValue<string>("Restly:LogPath") ?? "logs\\restly_agent.log";
Directory.CreateDirectory(Path.GetDirectoryName(logPath) ?? "logs");
Log.Logger = new LoggerConfiguration().WriteTo.File(logPath, rollingInterval: Serilog.RollingInterval.Day).CreateLogger();
builder.Host.UseSerilog();

builder.Services.AddHostedService<SocketAgentService>();
builder.Host.UseWindowsService();

var app = builder.Build();
app.Run();
