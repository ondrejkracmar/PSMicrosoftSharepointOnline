using System;
using System.Runtime.Serialization;


namespace PSMicrosoftSharepointOnline.Files.Drives
{
    /// <summary>
    /// Represents a SharePoint Online / Microsoft Graph Folder (document library root or subfolder).
    /// Designed for JSON (de)serialization via DataContract and DataMember attributes.
    /// </summary>
    [DataContract]
    public class Drive
    {

        /// <summary>
        /// The unique identifier of the folder.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// The display name of the folder.
        /// </summary>
        [DataMember(Name = "name", EmitDefaultValue = false)]
        public string Name { get; set; }

        /// <summary>
        /// The folder description.
        /// </summary>
        [DataMember(Name = "description", EmitDefaultValue = false)]
        public string Description { get; set; }

        /// <summary>
        /// The web URL of the folder.
        /// </summary>
        [DataMember(Name = "webUrl", EmitDefaultValue = false)]
        public string WebUrl { get; set; }

        /// <summary>
        /// The date and time when the folder was created.
        /// </summary>
        [DataMember(Name = "createdDateTime", EmitDefaultValue = false)]
        public string CreatedDateTime { get; set; }

        /// <summary>
        /// The date and time when the folder was last modified.
        /// </summary>
        [DataMember(Name = "lastModifiedDateTime", EmitDefaultValue = false)]
        public string LastModifiedDateTime { get; set; }

        /// <summary>
        /// The drive type (e.g., "documentLibrary").
        /// </summary>
        [DataMember(Name = "driveType", EmitDefaultValue = false)]
        public string DriveType { get; set; }


        /// <summary>
        /// Quota information for the folder (storage usage, remaining space, etc.).
        /// </summary>
        [DataMember(Name = "quota", EmitDefaultValue = false)]
        public Quota Quota { get; set; }
    }
}
