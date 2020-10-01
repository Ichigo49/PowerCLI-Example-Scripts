# **************************************************************************
#  Copyright 2020 VMware, Inc.
# **************************************************************************

param(
    [Parameter(Mandatory = $true)]
    [string]
    $VcAddress,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

# Import Vmware.vSphere.SsoAdmin Module
$modulePath = Join-Path (Split-Path $PSScriptRoot | Split-Path) "VMware.vSphere.SsoAdmin.psd1"
Import-Module $modulePath

Describe "TokenLifetime Tests" {
   BeforeEach {
      Connect-SsoAdminServer `
         -Server $VcAddress `
         -User $User `
         -Password $Password `
         -SkipCertificateCheck
   }

   AfterEach {
      $connectionsToCleanup = $global:DefaultSsoAdminServers.ToArray()
      foreach ($connection in $connectionsToCleanup) {
         Disconnect-SsoAdminServer -Server $connection
      }
   }

   Context "Get-TokenLifetime" {
      It 'Gets token lifetime settings' {
         # Act
         $actual = Get-TokenLifetime

         # Assert
         $actual | Should Not Be $null
         $actual.MaxHoKTokenLifetime | Should BeGreaterThan 0
         $actual.MaxBearerTokenLifetime | Should BeGreaterThan 0
      }
   }

   Context "Set-TokenLifetime" {
      It 'Updates MaxHoKTokenLifetime and MaxBearerTokenLifetime' {
         # Arrange
         $tokenLifetimeToUpdate = Get-TokenLifetime
         $expectedMaxHoKTokenLifetime = 60
         $expectedMaxBearerTokenLifetime = 30

         # Act
         $actual = Set-TokenLifetime `
            -TokenLifetime $tokenLifetimeToUpdate `
            -MaxHoKTokenLifetime $expectedMaxHoKTokenLifetime `
            -MaxBearerTokenLifetime $expectedMaxBearerTokenLifetime

         # Assert
         $actual | Should Not Be $null
         $actual.MaxHoKTokenLifetime | Should Be $expectedMaxHoKTokenLifetime
         $actual.MaxBearerTokenLifetime | Should Be $expectedMaxBearerTokenLifetime

         # Cleanup
         $tokenLifetimeToUpdate | Set-TokenLifetime `
            -MaxHoKTokenLifetime $tokenLifetimeToUpdate.MaxHoKTokenLifetime `
            -MaxBearerTokenLifetime $tokenLifetimeToUpdate.MaxBearerTokenLifetime
      }
   }
}