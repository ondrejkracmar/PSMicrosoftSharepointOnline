using System;
using System.Runtime.Serialization;
using Microsoft.PowerShell.Commands;

namespace PSMicrosoftSharePointOnline.Files.Drives
{
    /// <summary>
    /// Represents file-specific metadata for a drive item.
    /// </summary>
    [DataContract]
    public class FileMetadata
    {
        /// <summary>
        /// MIME type of the file (e.g., "application/pdf").
        /// </summary>
        [DataMember(Name = "mimeType", EmitDefaultValue = false)]
        public string MimeType { get; set; }

        /// <summary>
        /// Optional content hashes returned by Graph (e.g., quickXorHash).
        /// </summary>
        [DataMember(Name = "hashes", EmitDefaultValue = false)]
        public FileHashInfo Hashes { get; set; }
    }

}
