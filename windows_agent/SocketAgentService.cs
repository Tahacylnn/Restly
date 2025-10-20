using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SocketIOClient;
using Newtonsoft.Json.Linq;
using Serilog;

public class SocketAgentService : IHostedService, IDisposable
{
    private readonly IConfiguration _config;
    private readonly ILogger<SocketAgentService> _logger;
    private SocketIO? _client;
    private Timer? _heartbeatTimer;
    private string _wsUrl;
    private string _jwt;
    private int _reconnectDelay;

    public SocketAgentService(IConfiguration config, ILogger<SocketAgentService> logger)
    {
        _config = config;
        _logger = logger;
        _wsUrl = _config.GetValue<string>("Restly:WsUrl") ?? "http://localhost:3000";
        _jwt = _config.GetValue<string>("Restly:Jwt") ?? "";
        _reconnectDelay = _config.GetValue<int>("Restly:ReconnectDelayMs", 3000);
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("SocketAgentService starting...");
        await ConnectAsync();
    }

    private async Task ConnectAsync()
    {
        try
        {
            var options = new SocketIOOptions {
                Query = new System.Collections.Generic.Dictionary<string,string> { { "token", _jwt } },
                Reconnection = false
            };
            _client = new SocketIO(_wsUrl, options);

            _client.OnConnected += async (s,e) => {
                _logger.LogInformation("Connected to server");
                await _client.EmitAsync("agent:hello", new { platform = "windows", ts = DateTime.UtcNow });
            };
            _client.OnDisconnected += (s,e) => {
                _logger.LogWarning("Disconnected: {0}", e);
            };
            _client.On("message", response => {
                try {
                    var json = response.GetValue().ToString();
                    _logger.LogInformation("Message: {0}", json);
                    HandleServerMessage(json);
                } catch(Exception ex) {
                    _logger.LogError(ex, "Error handling message");
                }
            });
            _client.OnError += (s, err) => {
                _logger.LogError("Socket error: {0}", err);
            };

            await _client.ConnectAsync();

            _heartbeatTimer = new Timer(async _ => {
                if (_client != null && !_client.Connected) {
                    _logger.LogWarning("Socket disconnected, trying reconnect...");
                    try {
                        await _client.ConnectAsync();
                    } catch (Exception ex) {
                        _logger.LogError(ex, "Reconnect failed");
                        await Task.Delay(_reconnectDelay);
                    }
                }
            }, null, 5000, 5000);
        }
        catch(Exception ex) {
            _logger.LogError(ex, "ConnectAsync failed, scheduling reconnect");
            await Task.Delay(_reconnectDelay);
            await ConnectAsync();
        }
    }

    private void HandleServerMessage(string json)
    {
        try {
            var j = JObject.Parse(json);
            var type = j.Value<string>("type");
            if (type == "lock") {
                var breakId = j.Value<string>("breakId");
                _logger.LogInformation("Lock requested: {0}", breakId);
                NativeMethods.LockWorkStation();
            } else if (type == "unlock") {
                _logger.LogInformation("Unlock requested");
            } else if (type == "force_input_block") {
                var dur = j.Value<int?>("durationSec") ?? 0;
                _logger.LogInformation("Force block input for {0}s", dur);
                NativeMethods.BlockInput(true);
                Task.Delay(TimeSpan.FromSeconds(dur)).ContinueWith(_ => NativeMethods.BlockInput(false));
            } else {
                _logger.LogInformation("Unhandled type: {0}", type);
            }
        } catch(Exception ex) {
            _logger.LogError(ex, "HandleServerMessage parse error");
        }
    }

    public async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("SocketAgentService stopping...");
        _heartbeatTimer?.Change(Timeout.Infinite, 0);
        if (_client != null) {
            try { await _client.DisconnectAsync(); } catch {}
            _client.Dispose();
        }
    }

    public void Dispose()
    {
        _heartbeatTimer?.Dispose();
    }
}
