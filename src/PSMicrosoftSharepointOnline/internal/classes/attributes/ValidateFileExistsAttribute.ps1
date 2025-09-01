$ValidateFileExistsAttributeCode = @'
using System;
using System.IO;
using System.Management.Automation;

    /// <summary>
    /// Ensures that the parameter value is a valid, existing file path.
    /// Throws a ValidationMetadataException if the file does not exist.
    /// </summary>
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Field)]
    public sealed class ValidateFileExistsAttribute : ValidateArgumentsAttribute
    {
        /// <summary>
        /// Validates that the argument is an existing file path.
        /// </summary>
        /// <param name="arguments">The parameter value passed in.</param>
        /// <param name="engineIntrinsics">Engine intrinsics.</param>
        protected override void Validate(object arguments, EngineIntrinsics engineIntrinsics)
        {
            if (arguments == null)
            {
                throw new ValidationMetadataException("File path cannot be null.");
            }

            string path = arguments as string;
            if (string.IsNullOrWhiteSpace(path))
            {
                throw new ValidationMetadataException("File path cannot be empty.");
            }

            if (!File.Exists(path))
            {
                throw new ValidationMetadataException(
                    $"The file '{path}' does not exist or is not accessible.");
            }
        }
    }
'@

# compile c# code if not already loaded
Try{
    if( [ValidateFileExistsAttribute] -as [type]){

    }
}
catch{
    Add-Type -TypeDefinition $ValidateFileExistsAttributeCode
}
