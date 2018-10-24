using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Compilation;
using System.Web.Hosting;
using System.Web.Routing;
using System.Web.UI;

/// <summary>
/// CompactRESTRouteHandler 的摘要描述
/// </summary>
public class CompactRESTRouteHandler : IRouteHandler
{   
    public IHttpHandler GetHttpHandler(RequestContext requestContext)
    {
        var routeData = requestContext.RouteData;

        // 取出參數
        string model = Convert.ToString(routeData.Values["model"]);
        string id = Convert.ToString(routeData.Values["id"]);

        HttpContext.Current.Items.Add("model", model);

        if (!string.IsNullOrEmpty(id))
        {
            HttpContext.Current.Items.Add("id", id);
        }

        // 檢查看看有無該 Model 對應的 ASHX
        string ashxName = model + "Handler.ashx";
        
        // 找不到的話
        if (!File.Exists(HostingEnvironment.MapPath("~/api/" + ashxName)))
        {
            return BuildManager.CreateInstanceFromVirtualPath("~/NotFound.aspx", typeof(Page)) as Page;
        }

        // 導向指定的 ASHX
        return BuildManager.CreateInstanceFromVirtualPath("~/API/" + ashxName, typeof(IHttpHandler)) as IHttpHandler;
    }
}