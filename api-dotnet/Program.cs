using System;
using System.IO;
using Microsoft.AspNetCore.Hosting;

namespace ApiDotNet
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // ASP.NET Core will support ASPNETCORE_URLS in RTM and this line can be removed then.
            string url = Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://*:5000";
            
            var webHost = new WebHostBuilder().UseKestrel()
                                              .UseContentRoot(Directory.GetCurrentDirectory())                        
                                              .UseStartup<Startup>()
                                              .UseUrls(url)
                                              .Build();

            webHost.Run();
        }
    }
}