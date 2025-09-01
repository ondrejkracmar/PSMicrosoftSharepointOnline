using System.Runtime.Serialization;

namespace PSMicrosoftSharepointOnline.Files.Drives
{
    /// <summary>
    /// Represents quota information for a SharePoint folder or document library.
    /// Contains storage usage details such as total space, used space, and remaining quota.
    /// </summary>
    [DataContract]
    public class Quota
    {
        /// <summary>
        /// The total amount of space freed up after items were deleted (in bytes).
        /// </summary>
        [DataMember(Name = "deleted", EmitDefaultValue = false)]
        public long Deleted { get; set; }

        /// <summary>
        /// The amount of available storage space remaining (in bytes).
        /// </summary>
        [DataMember(Name = "remaining", EmitDefaultValue = false)]
        public long Remaining { get; set; }

        /// <summary>
        /// The current state of the storage quota (e.g., "normal", "nearLimit", "exceeded").
        /// </summary>
        [DataMember(Name = "state", EmitDefaultValue = false)]
        public string State { get; set; }

        /// <summary>
        /// The total size of the storage quota (in bytes).
        /// </summary>
        [DataMember(Name = "total", EmitDefaultValue = false)]
        public long Total { get; set; }

        /// <summary>
        /// The amount of storage space currently used (in bytes).
        /// </summary>
        [DataMember(Name = "used", EmitDefaultValue = false)]
        public long Used { get; set; }
    }
}