using Microsoft.AspNetCore.Mvc;
using System;

namespace ApiDotNet.Controllers
{
    [Route("/api/hello")]
    public class HelloController
    {
        [HttpGet]
        public string Get()
        {
            return $"Hello from api-dotnet at: {DateTimeOffset.UtcNow.ToString("u")}";
        }
    }
}
