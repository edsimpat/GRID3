using System;
using GlobalResale.GRID3.Core.Interfaces;

namespace GlobalResale.GRID3.Core.Domain
{
    public abstract class PersistentObject : BasePersistentObject, IOrganizationEntity
    {
        public virtual Organization Organization { get; set; }
        public virtual User CreatedBy { get; set; }
    }

    public abstract class BasePersistentObject : IPersistentObject
    {
        public virtual Guid Id { get; set; }

    }
}
