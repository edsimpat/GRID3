using System.Threading.Tasks;
using GlobalResale.GRID3.Api.Extensions;
using GlobalResale.GRID3.Api.Features.Token;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace GlobalResale.GRID3.Api.Controllers
{
    [Route(Endpoints.Token)]
    [ApiController]
    public class TokenController : ControllerBase
    {
        private readonly IMediator _mediator;

        public TokenController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<ActionResult<TokenResult>> Post([FromBody]TokenRequest request)
        {
            request.BaseUrl(Request.GetUriLeftPart());
            var result = await _mediator.Send(request);

            if (result == null)
            {
                return BadRequest("The API Key and/or API Secret do not match our records.");
            }

            return result;
        }
    }
}
