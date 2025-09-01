using System;
using System.Runtime.Serialization;
using PSMicrosoftSharepointOnline.Files.Drives;

namespace PSMicrosoftSharePointOnline.Files.Drives
{
    /// <summary>
    /// Represents a file or folder item in a SharePoint Online / Teams document library.
    /// Maps to the Microsoft Graph 'driveItem' resource returned by children listings.
    /// </summary>
    [DataContract]
    public class DriveItem
    {
        /// <summary>
        /// Unique identifier of the item.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Display name of the item (file name or folder name).
        /// </summary>
        [DataMember(Name = "name", EmitDefaultValue = false)]
        public string Name { get; set; }

        /// <summary>
        /// Browser URL pointing to the item.
        /// </summary>
        [DataMember(Name = "webUrl", EmitDefaultValue = false)]
        public string WebUrl { get; set; }

        /// <summary>
        /// Entity tag for optimistic concurrency control.
        /// </summary>
        [DataMember(Name = "eTag", EmitDefaultValue = false)]
        public string ETag { get; set; }

        /// <summary>
        /// Content tag that changes when the item's content is updated (often omitted for folders).
        /// </summary>
        [DataMember(Name = "cTag", EmitDefaultValue = false)]
        public string CTag { get; set; }

        /// <summary>
        /// Size of the item in bytes (folders may return null or 0).
        /// </summary>
        [DataMember(Name = "size", EmitDefaultValue = false)]
        public long? Size { get; set; }

        /// <summary>
        /// Date and time when the item was created (with timezone offset).
        /// </summary>
        [DataMember(Name = "createdDateTime", EmitDefaultValue = false)]
        public string? CreatedDateTime { get; set; }

        /// <summary>
        /// Date and time when the item was last modified (with timezone offset).
        /// </summary>
        [DataMember(Name = "lastModifiedDateTime", EmitDefaultValue = false)]
        public string? LastModifiedDateTime { get; set; }

        /// <summary>
        /// File-specific metadata; present when the item is a file.
        /// </summary>
        [DataMember(Name = "file", EmitDefaultValue = false)]
        public FileMetadata File { get; set; }

        /// <summary>
        /// Folder-specific metadata; present when the item is a folder.
        /// </summary>
        [DataMember(Name = "folder", EmitDefaultValue = false)]
        public FolderMetadata Folder { get; set; }

        /// <summary>
        /// Reference to the parent container; includes drive and path information.
        /// Useful for reconstructing drive-relative paths.
        /// </summary>
        [DataMember(Name = "parentReference", EmitDefaultValue = false)]
        public ParentItemInfo ParentReference { get; set; }
    }
}