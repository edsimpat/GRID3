using System;
using GlobalResale.GRID3.Core.Interfaces;

namespace GlobalResale.GRID3.Core.Domain
{
    public class Role
    {
        public virtual Organization Organization { get; set; }
        public virtual User CreatedBy { get; set; }
    }
}
