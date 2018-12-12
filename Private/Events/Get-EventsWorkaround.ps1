function Get-EventsWorkaround {
    [CmdLetBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $IgnoreWords
    )
    DynamicParam {
        # Defines Report / Dates Range dynamically from HashTables
        $Names = $Script:ReportDefinitions.Keys

        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $true
        $ParamAttrib.ParameterSetName = '__AllParameterSets'

        $ReportAttrib = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $ReportAttrib.Add($ParamAttrib)
        $ReportAttrib.Add((New-Object System.Management.Automation.ValidateSetAttribute($Names)))

        $ReportRuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Report', [string], $ReportAttrib)

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Report', $ReportRuntimeParam)
        return $RuntimeParamDic
    }
    Process {
        [string] $ReportName = $PSBoundParameters.Report

        $MyReportDefinitions = $Script:ReportDefinitions.$ReportName



        #$EventsType = $MyReportDefinitions.$ReportName.Events.LogName
        #$EventsNeeded = $MyReportDefinitions.$ReportName.Events.Events



        foreach ($Report in $MyReportDefinitions.Keys | Where-Object { $_ -ne 'Enabled' }) {

            $MyReportDefinitions.$Report.IgnoreWords = $IgnoreWords
            $EventsType = $MyReportDefinitions[$Report].LogName
            $EventsNeeded = $MyReportDefinitions[$Report].Events


            $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType

            Write-Color "Test ", $Report, ' ', $ReportName, ' ', $EventsType, " ", $EventsNeeded, " count ", $EventsFound.Count -Color Red
            $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $MyReportDefinitions[$Report]
            Write-Color "Count " , $EventsFound.Count -Color Red
            $EventsFound
        }

        #$EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
        #return Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.$ReportName
    }
}