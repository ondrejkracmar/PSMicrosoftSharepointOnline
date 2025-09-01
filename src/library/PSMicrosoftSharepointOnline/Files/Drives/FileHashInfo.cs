using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PSMicrosoftSharePointOnline.Files.Drives
{
    /// <summary>
    /// Represents content hash information for a file.
    /// </summary>
    [DataContract]
    public class FileHashInfo
    {
        /// <summary>
        /// QuickXor hash commonly used by OneDrive/SharePoint for file change detection.
        /// </summary>
        [DataMember(Name = "quickXorHash", EmitDefaultValue = false)]
        public string QuickXorHash { get; set; }
    }
}
