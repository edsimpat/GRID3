using GlobalResale.GRID3.Core.Domain;

namespace GlobalResale.GRID3.Core.Interfaces
{
    public interface IUserContext
    {
        User CurrentUser { get; set; }
        Organization CurrentOrganization { get; set; }
    }
}
