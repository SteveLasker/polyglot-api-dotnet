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

            var message = string.Format("Hello from api-dotnet running on: {1}", 
                osDescription);

            return message;
        }
    }
}
