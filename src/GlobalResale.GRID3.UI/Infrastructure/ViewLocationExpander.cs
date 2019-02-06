using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.AspNetCore.Mvc.Razor;

[assembly: AspMvcViewLocationFormat("~/Features/{1}/{0}.cshtml")]
[assembly: AspMvcViewLocationFormat("~/Features/Shared/{0}.cshtml")]

namespace GlobalResale.GRID3.UI.Infrastructure
{
    public class ViewLocationExpander : IViewLocationExpander
    {
        public void PopulateValues(ViewLocationExpanderContext context)
        {
            context.Values["customviewlocation"] = nameof(ViewLocationExpander);
        }

        public IEnumerable<string> ExpandViewLocations(ViewLocationExpanderContext context, IEnumerable<string> viewLocations)
        {
            //{1} is controller,{0} is the action
            var locations = new [] { "/Features/{1}/{0}.cshtml" , "/Features/Shared/{0}.cshtml" };
            return locations;
        }
    }
}
