using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using GlobalResale.GRID3.Api.Infrastructure;
using MediatR;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace GlobalResale.GRID3.Api.Features.Token
{
    public class TokenRequestHandler : IRequestHandler<TokenRequest, TokenResult>
    {
        private readonly JwtSettings _jwtSettings;

        public TokenRequestHandler(IOptions<JwtSettings> jwtSettingsOptions)
        {
            _jwtSettings = jwtSettingsOptions.Value;
        }

        public async Task<TokenResult> Handle(TokenRequest request, CancellationToken cancellationToken)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.Name, request.ApiKey)
            };
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.JwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: request.BaseUrl(),
                audience: request.BaseUrl(),
                claims: claims,
                expires: DateTime.Now.AddDays(_jwtSettings.JwtTokenExpireDays),
                signingCredentials: creds);

            return new TokenResult
            {
                Expiration = token.ValidTo.ToString("u"),
                Token = new JwtSecurityTokenHandler().WriteToken(token)
            };
        }
    }
}
