using System.Threading.Tasks;
using GlobalResale.GRID3.Web.Features.ApiConfiguration;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GlobalResale.GRID3.Web.Controllers
{
    [Authorize]
    public class ApiConfigurationController : Controller
    {
        private readonly IMediator _mediator;

        public ApiConfigurationController(IMediator mediator)
        {
            _mediator = mediator;
        }

        public async Task<IActionResult> Index()
        {
            var model = await _mediator.Send(new IndexQuery());
            return View(model);
        }
    }
}
