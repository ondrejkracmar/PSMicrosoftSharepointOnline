using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PSMicrosoftSharePointOnline.Files.Drives
{
    /// <summary>
    /// Contains reference information about the parent/container of a drive item.
    /// </summary>
    [DataContract]
    public class ParentItemInfo
    {
        /// <summary>
        /// Identifier of the drive that contains this item.
        /// </summary>
        [DataMember(Name = "driveId", EmitDefaultValue = false)]
        public string DriveId { get; set; }

        /// <summary>
        /// Type of the drive (e.g., "documentLibrary").
        /// </summary>
        [DataMember(Name = "driveType", EmitDefaultValue = false)]
        public string DriveType { get; set; }

        /// <summary>
        /// Composite path of the parent within the drive (e.g., "/drive/root:/Folder/Subfolder").
        /// </summary>
        [DataMember(Name = "path", EmitDefaultValue = false)]
        public string Path { get; set; }

        /// <summary>
        /// Identifier of the parent item (container).
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Display name of the parent item.
        /// </summary>
        [DataMember(Name = "name", EmitDefaultValue = false)]
        public string Name { get; set; }
    }
}
