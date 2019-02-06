using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace GlobalResale.GRID3.UI.Features.ApiConfiguration
{
    public class IndexQueryHandler : IRequestHandler<IndexQuery, IndexViewModel>
    {
        public Task<IndexViewModel> Handle(IndexQuery request, CancellationToken cancellationToken)
        {
            return Task.FromResult(new IndexViewModel());
        }
    }
}
