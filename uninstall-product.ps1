<#
.SYNOPSIS
  Script is designed to find all currently installed versions of Sophos Endoint Protection and uninstall.

.DESCRIPTION
  Uninstall all installed versions of Sophos Endpoint Protection.

.INPUTS
  productName [optional] 

.OUTPUTS
  Console output and Exit Code

.NOTES
  Author:         Lucas Halbert <contactme@lhalbert.xyz>
  Version:        2020.10.12
  Date Written:   10/12/2020
  Date Modified:  10/12/2020

  Revisions:      2020.10.12 - Inital draft

.EXAMPLE
  .\uninstall-product.ps1 

.LICENSE
  License:        BSD 3-Clause License

  Copyright (c) 2020, Lucas Halbert
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and#or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# Gather paramters
param(
    [Parameter(Mandatory=$false)][string]$productName
)


#---------------------------------------------------------[Initialisations]--------------------------------------------------------#
# Initialize system.timeoutException exception object
$timeoutException = new-object system.timeoutException


#----------------------------------------------------------[Declarations]----------------------------------------------------------#
# Declare Product Name
if($productName -eq $null -or $productName -eq "")
{
    $producName = 'sophos'
}

# Declare a counter for uninstall Errors
$uninstallErrors = 0


#-----------------------------------------------------------[Functions]------------------------------------------------------------#
# Functio to enumerate installed products by name
function Get-Installed-Products($name) {
    return get-wmiobject Win32_Product | Where-object {$_.Name -like "$name*"}
}



#-----------------------------------------------------------[Execution]------------------------------------------------------------#


# Get all installed products
$installedProducts = Get-Installed-Products($productName)
if(! $installedProducts) {
    Write-Host "The product '$productName' does not appear to be installed on this system"
    Exit 0
}

# Loop through all installed products and try to uninstall
$installedProducts | ForEach-Object {
    Try
    {
        Write-Host "Attempting to uninstall '$($_.Name)' v'$($_.Version)'"
        
        # Attempt to uninstall
        $_.Uninstall()
    }
    Catch
    {
        Write-Host "ERROR: Caught an unexpected exception while uninstalling '$productName': $_.Exception.Message"
        $uninstallErrors++
    }
}

If ($uninstallErrors -eq 0)
{        
    Write-Host "OK: All '$productName' products have been successfully removed."
    $installedProducts | Select Name, Version, IdentifyingNumber | ft
    Exit 0
}
Else
{   
    Write-Host "ERROR: Not all '$ProductName' products were successfully removed."
    Exit 1
}