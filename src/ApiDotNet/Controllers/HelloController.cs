using Microsoft.AspNetCore.Mvc;
using System;
using System.Runtime.InteropServices;

namespace ApiDotNet.Controllers
{
    [Route("/api/hello")]
    public class HelloController
    {
        [HttpGet]
        public string Get()
        {
            var osDescription = RuntimeInformation.OSDescription;
            var machineName = Environment.MachineName;

            // TimeZoneInfo has unique Ids per OS
            // Querying the wrong string will throw
            TimeZoneInfo tzInfo = null;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                tzInfo = TimeZoneInfo.FindSystemTimeZoneById("Pacific Standard Time");

            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                tzInfo = TimeZoneInfo.FindSystemTimeZoneById("America/Los_Angeles");

            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                tzInfo = TimeZoneInfo.FindSystemTimeZoneById("America/Los_Angeles");

            else
                tzInfo = TimeZoneInfo.FindSystemTimeZoneById(TimeZoneInfo.Local.Id);

            var message = string.Format("Hello from api-dotnet FRIDAY YEAH running on: {0} {1}", 
                osDescription,
                tzInfo.ToString());

            return message;
        }
    }
}
