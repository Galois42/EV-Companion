using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EV_ford
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnPlanJourney_Click(object sender, EventArgs e)
        {
            // Stockez les valeurs dans la session
            Session["Home"] = txtHome.Text;
            Session["Destination"] = txtDestination.Text;

            // Redirigez vers WebForm2.aspx
            Response.Redirect("WebForm2.aspx");
        }
    }
}