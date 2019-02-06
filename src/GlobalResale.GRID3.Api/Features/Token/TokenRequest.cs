using MediatR;

namespace GlobalResale.GRID3.Api.Features.Token
{
    public class TokenRequest : IRequest<TokenResult>
    {
        public string ApiKey { get; set; }
        public string ApiSecret { get; set; }

        private string _baseUrl;

        public void BaseUrl(string baseUrl)
        {
            _baseUrl = baseUrl;
        }

        public string BaseUrl()
        {
            return _baseUrl;
        }
    }
}
