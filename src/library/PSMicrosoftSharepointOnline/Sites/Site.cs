using System;
using System.Runtime.Serialization;
using PSMicrosoftSharepointOnline.Sites;

namespace PSMicrosoftSharePointOnline.Sites
{
    /// <summary>
    /// Represents a SharePoint Online site as returned by Microsoft Graph API (v1.0).
    /// Includes basic metadata such as identifiers, display name, description, URLs,
    /// and references to site collection and root properties.
    /// </summary>
    [DataContract]
    public class Site
    {
        /// <summary>
        /// The unique identifier of the site in the format: hostname,siteId,webId.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// The internal site name (short name, e.g. "BI4SG").
        /// </summary>
        [DataMember(Name = "name", EmitDefaultValue = false)]
        public string Name { get; set; }

        /// <summary>
        /// The display name of the site (user-friendly title).
        /// </summary>
        [DataMember(Name = "displayName", EmitDefaultValue = false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// The site description, if defined.
        /// </summary>
        [DataMember(Name = "description", EmitDefaultValue = false)]
        public string Description { get; set; }

        /// <summary>
        /// The full web URL of the site (browser accessible).
        /// </summary>
        [DataMember(Name = "webUrl", EmitDefaultValue = false)]
        public string WebUrl { get; set; }

        /// <summary>
        /// The date and time when the site was created.
        /// </summary>
        [DataMember(Name = "createdDateTime", EmitDefaultValue = false)]
        public string CreatedDateTime { get; set; }

        /// <summary>
        /// The date and time when the site was last modified.
        /// </summary>
        [DataMember(Name = "lastModifiedDateTime", EmitDefaultValue = false)]
        public string LastModifiedDateTime { get; set; }

        /// <summary>
        /// Indicates that this is the root site (present if the site is a root site).
        /// Typically contains an empty object when returned.
        /// </summary>
        [DataMember(Name = "root", EmitDefaultValue = false)]
        public object Root { get; set; }

        /// <summary>
        /// Provides information about the site collection that the current site belongs to.
        /// Contains metadata such as the hostname of the tenant-level site collection.
        /// This property helps identify the root site collection context of the site.
        /// </summary>
        [DataMember(Name = "siteCollection", EmitDefaultValue = false)]
        public SiteCollection SiteCollection { get; set; }
    }
}
