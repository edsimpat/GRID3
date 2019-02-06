using System;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Reflection;

namespace GlobalResale.GRID3.Core.Domain
{
    public static class PermissionExtensions
    {
        public static DisplayAttribute GetDisplayAttribute(this Permission value)
        {
            var memberInfo = value.GetType().GetMember(value.ToString()).SingleOrDefault();

            return memberInfo != null ? memberInfo.GetCustomAttribute<DisplayAttribute>() : null;
        }
    }

    public enum Permission
    {

        #region Special Permissions

        //Special Permissions (These may be out of order) 1-20
        [NotAssignable]
        [Display(Name = "Default", GroupName = "Non-Assignable", Description = "Default permission for starting a solution")]
        Default = 1,
        //[NotAssignable]
        [Display(Name = "Organization API Admin", GroupName = "Non-Assignable", Description = "Default permission for setting APIs information.")]
        OrganizationApiAdmin = 2,
        //[NotAssignable]
        [Display(Name = "View Error Log", GroupName = "Non-Assignable", Description = "Allows a user to view the Elmah error log.")]
        ViewErrorLog = 3,
        [NotAssignable]
        [Display(Name = "File Permission", GroupName = "Non-Assignable", Description = "A permission to prevent unauthorized/invalid access to Not Implemented File Controller methods.")]
        FilePermission = 4,

        #endregion
        
    }

    public class NotAssignable : Attribute
    {
    }
}