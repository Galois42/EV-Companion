using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EV_ford
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var home = Session["Home"] as string;
                var destination = Session["Destination"] as string;

                // Utilisez `home` et `destination` ici pour effectuer d'autres opérations
            }
        }
    }
}