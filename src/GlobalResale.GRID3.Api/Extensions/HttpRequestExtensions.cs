using Microsoft.AspNetCore.Http;

namespace GlobalResale.GRID3.Api.Extensions
{
    public static class HttpRequestExtensions
    {
        public static string GetUriLeftPart(this HttpRequest request)
        {
            return $"{request.Scheme}://{request.Host}";
        }
    }
}
