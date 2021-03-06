Function Set-Environment 
{
	<#
			.SYNOPSIS
			Sets global module config variables AccessToken, CloudProvider and ApirRootUrl    
			.DESCRIPTION
			Sets global module config variables AccessToken, CloudProvider and ApirRootUrl    
			.PARAMETER PBIAPIUrl
			The url for the PBI API
			.PARAMETER AccessToken
			The AccessToken to use to access the Databricks API
			For example: dapi1234abcd32101691ded20b53a1326285
			.PARAMETER ApiRootUrl
			The URL of the API. 
			For Azure, this could be 'https://westeurope.azuredatabricks.net'
			For AWS, this could be 'https://abc-12345-xaz.cloud.databricks.com'
			.PARAMETER CloudProvider
			The CloudProvider where the Databricks workspace is hosted. Can either be 'Azure' or 'AWS'.
			If not provided, it is derived from the ApiRootUrl parameter
			.EXAMPLE
			Set-Environment -AccessToken "dapi1234abcd32101691ded20b53a1326285" -ApiRootUrl "https://abc-12345-xaz.cloud.databricks.com"
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, Position = 1)] [string] $AccessToken,
		[Parameter(Mandatory = $true, Position = 2)] [string] $ApiRootUrl,
		[Parameter(Mandatory = $false, Position = 3)] [string] [ValidateSet("Azure","AWS")] $CloudProvider = $null
	)

	Write-Verbose "Setting [System.Net.ServicePointManager]::SecurityProtocol to [System.Net.SecurityProtocolType]::Tls12 ..."
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
	Write-Verbose "Done!"

	#region check AccessToken
	$paramToCheck = 'AccessToken'
	Write-Verbose "Checking if Parameter -$paramToCheck was provided ..."
	if($AccessToken -ne $null)
	{
		Write-Verbose "Parameter -$paramToCheck provided! Setting global $paramToCheck ..."
		$script:dbAccessToken = $AccessToken
		Write-Verbose "Done!"
	}
	else
	{
		Write-Warning "Parameter -$paramToCheck was not provided!"
	}
	#endregion

	#region check ApiRootUrl
	$paramToCheck = 'ApiRootUrl'
	Write-Verbose "Checking if Parameter -$paramToCheck was provided ..."
	if($ApiRootUrl -ne $null)
	{
		Write-Verbose "$paramToCheck provided! Setting global $paramToCheck ..."
		$script:dbApiRootUrl = $ApiRootUrl.Trim('/') + "/api"
		Write-Verbose "Done!"
	}
	else
	{
		Write-Warning "Parameter -$paramToCheck was not provided!"
	}

	#region check CloudProvider
	$paramToCheck = 'CloudProvider'
	Write-Verbose "Checking if Parameter -$paramToCheck was provided ..."
	if($CloudProvider -ne $null)
	{
		Write-Verbose "Parameter -$paramToCheck provided! Setting global $paramToCheck ..."
		$script:dbCloudProvider = $CloudProvider
		Write-Verbose "Done!"
	}
	else
	{
		Write-Warning "Parameter -$paramToCheck was not provided!"
		Write-Verbose "Trying to derive $paramToCheck from ApiRootUrl ..."
		Write-Verbose "Checking if ApiRootUrl contains '.azuredatabricks.' ..."
		if($ApiRootUrl -ilike "*.azuredatabricks.*")
		{
			Write-Verbose "'.azuredatabricks.' found in ApiRootUrl - Setting CloudProvider to 'Azure' ..."
			$script:dbCloudProvider = "Azure"
		}
		else
		{
			Write-Verbose "'.azuredatabricks.' found in ApiRootUrl - Setting CloudProvider to 'AWS' ..."
			$script:dbCloudProvider = "AWS"
		}
		Write-Verbose "Done!"
	}
	#endregion

	$script:dbInitialized = $true
}

Function Test-Environment
{
	<#
			.SYNOPSIS
			List the contents of a given path in a Databricks workspace
			.DESCRIPTION
			Lists the contents of a directory, or the object if it is not a directory. If the input path does not exist, this call returns an error RESOURCE_DOES_NOT_EXIST.
			Official API Documentation: https://docs.databricks.com/api/latest/workspace.html#list
			.EXAMPLE
			Test-Environment
	#>
	[CmdletBinding()]
	param ()

	Test-Initialized
	
	$Path = "/"

	Write-Verbose "Setting final ApiURL ..."
	$apiUrl = Get-ApiUrl -ApiEndpoint "/2.0/workspace/list"
	$requestMethod = "GET"
	Write-Verbose "API Call: $requestMethod $apiUrl"

	#Set headers
	$headers = Get-RequestHeader

	Write-Verbose "HEADERS: "
	Write-Verbose $headers.Values
	
	Write-Verbose "Setting Parameters for API call ..."
	#Set parameters
	$parameters = @{
		path = $Path 
	}
	
	Write-Verbose "PARAMETERS: "
	Write-Verbose $parameters.Values

	$result = Invoke-RestMethod -Uri $apiUrl -Method $requestMethod -Headers $headers -Body $parameters

	return $result
}

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

