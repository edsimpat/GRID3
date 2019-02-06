namespace GlobalResale.GRID3.Core.Domain
{
    public class RolePermission : PersistentObject
    {
        public virtual Permission Permission { get; set; }
        public virtual Role Role { get; set; }
    }
}
