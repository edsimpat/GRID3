namespace GlobalResale.GRID3.Core.Domain
{
    public class ApiKey : PersistentObject
    {
        public virtual string Key { get; set; }
        public virtual bool IsActive { get; set; }
    }
}
