$ValidateDirectoryExistsAttributeCode= @'
using System;
using System.IO;
using System.Management.Automation;

    /// <summary>
    /// Ensures that the parameter value is a valid, existing directory path.
    /// Throws a ValidationMetadataException if the directory does not exist.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Field)]
    public sealed class ValidateDirectoryExistsAttribute : ValidateArgumentsAttribute
    {
        /// <summary>
        /// Validates that the argument is an existing directory path.
        /// </summary>
        /// <param name="arguments">The parameter value passed in.</param>
        /// <param name="engineIntrinsics">Engine intrinsics.</param>
        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (arguments == null)
            {
                throw new ValidationMetadataException("Output directory path cannot be null.");
            }

            string path = arguments as string;
            if (string.IsNullOrWhiteSpace(path))
            {
                throw new ValidationMetadataException("Output directory path cannot be empty.");
            }

            if (!Directory.Exists(path))
            {
                throw new ValidationMetadataException(
                    $"The directory '{path}' does not exist or is not accessible.");
            }
        }
    }
'@
# compile c# code
Try{
    if( [ValidateDirectoryExistsAttribute] -as [type]){

    }
}
catch{
    Add-Type -TypeDefinition $ValidateDirectoryExistsAttributeCode
}