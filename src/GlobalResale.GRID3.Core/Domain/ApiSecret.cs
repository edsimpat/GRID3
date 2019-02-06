using System;

namespace GlobalResale.GRID3.Core.Domain
{
    public class ApiSecret : PersistentObject
    {
        public virtual DateTime LastUpdatedDateTime { get; set; }
        public virtual bool ForceExpired { get; set; }
    }
}
