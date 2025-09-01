using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PSMicrosoftSharePointOnline.Files.Drives
{
    /// <summary>
    /// Represents folder-specific metadata for a drive item.
    /// </summary>
    [DataContract]
    public class FolderMetadata
    {
        /// <summary>
        /// Number of direct child items inside the folder.
        /// </summary>
        [DataMember(Name = "childCount", EmitDefaultValue = false)]
        public int? ChildCount { get; set; }
    }

}
