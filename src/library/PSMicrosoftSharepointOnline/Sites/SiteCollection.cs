using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PSMicrosoftSharepointOnline.Sites
{
    /// <summary>
    /// Represents site collection metadata for a site.
    /// </summary>
    [DataContract]
    public class SiteCollection
    {
        /// <summary>
        /// The hostname of the site collection (e.g. "contoso.sharepoint.com").
        /// </summary>
        [DataMember(Name = "hostname", EmitDefaultValue = false)]
        public string Hostname { get; set; }
    }
}
