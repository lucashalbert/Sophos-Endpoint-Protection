<#
.SYNOPSIS
  Script is designed to test if Sophos Endoint Protection is installed and proceed with uninstall.

.DESCRIPTION
  Uninstall Sophos Endpoint Protection.

.INPUTS
  none 

.OUTPUTS
  Console output and Exit Code

.NOTES
  Author:         Lucas Halbert <contactme@lhalbert.xyz>
  Version:        2020.10.13
  Date Written:   10/12/2020
  Date Modified:  10/13/2020

  Revisions:      2020.10.13 - Add try/catch/finally and run uninstallclie.exe provided with SOPHOS
                  2020.10.12 - Inital draft

.EXAMPLE
  .\uninstall-SEP.ps1 

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
    [switch]$WhatIf
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------#
#----------------------------------------------------------[Declarations]----------------------------------------------------------#
# Declare Product Name
$productName = 'sophos'

# Declare the default result
$result = $FALSE


#-----------------------------------------------------------[Functions]------------------------------------------------------------#
# Function to test if product is installed
function Is-Installed($name) {
    Write-host "Checking if $name is installed"
    if (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "$name*"}) {
        return $TRUE
    } else {
        return $FALSE
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------#


if(Is-Installed($productName)) {
  Try {
      Write-Host "Attempting to uninstall '$productName'"

      $filename = 'uninstallcli.exe'
      $directory = 'C:\Program Files\Sophos\Sophos Endpoint Agent'
      $path = "$directory\$filename"
      
      if($WhatIf) {
          # Perform the uninstall
          Write-Host "Whatif: Start-Process -FilePath $path -Wait -PassThru"
      } else {
          # Perform the uninstall
          $proc = Start-Process -FilePath $path -Wait -PassThru
          $proc.waitForExit()

          if($proc.ExitCode -ne 0) {
              throw "Errorlevel $($proc.ExitCode)"
          } else {
              $result = $TRUE
          }
      }
  } Catch {
      Write-Host "ERROR: Caught an unexpected exception while uninstalling '$productName': $_"
  }
  Finally {
      If($result) {
          Write-Host "OK: The product '$productName' has been successfully uninstalled from this system"
          Exit 0
      } Else {
          Write-Host "ERROR: The product'$ProductName' was NOT successfully uninstalled from this system."
          Exit 1
      }
  }
} Else {
    Write-Host "OK: The product '$productName' does not appear to be installed on this system"
    Exit 0
}