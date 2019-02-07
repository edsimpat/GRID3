using FluentNHibernate.Mapping;
namespace GlobalResale.GRID3.Core.Domain
{
    public class PersistentObjectMap : ClassMap<PersistentObject>
    {
        public PersistentObjectMap()
        {
            Map(x => x.Organization);
            Map(x => x.CreatedBy);
        }
    }

    public class BasePersistentObjectMap : ClassMap<BasePersistentObject>
    {
        public BasePersistentObjectMap()
        {
            Id(x => x.Id);
        }
    }
}
