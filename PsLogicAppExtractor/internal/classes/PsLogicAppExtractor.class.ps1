<#
."..\PsLogicAppExtractor\internal\classes\PsLogicAppExtractor.class.ps1"
#>
class Helper {
    Helper([object] $values) {
        if ($values -is [System.Collections.IDictionary]) {
            foreach ($key in $values.Keys) {
                if ($this.PSObject.Properties.Item($key)) {
                    $this.$key = $values[$key]
                }
            }
        }
        else {
            foreach ($property in $values.PSObject.Properties) {
                if ($this.PSObject.Properties.Item($property.Name)) {
                    $this.($property.Name) = $property.Value
                }
            }
        }
    }
}

class Definition: Helper {
    [object] ${$schema}
    [string] $contentVersion
    [object] $parameters
    [object] $triggers
    [object] $actions
    [object] $outputs

    Definition([object] $values) : base($values) { }
}

class Properties : Helper {
    [string] $state
    [Definition] $definition
    [object] $parameters
    [object] $integrationAccount
    [object] $accessControl
    
    Properties([object] $values) : base($values) { }
}

class LogicApp : Helper {
    [string] $type
    [string] $apiVersion
    [string] $name
    [string] $location
    [object] $tags
    [object] $identity
    [Properties] $properties

    LogicApp([object] $values) : base($values) { }
}

class ArmTemplate: Helper {
    [object] ${$schema}
    [string] $contentVersion
    [object] $parameters
    [object] $variables
    [object] $resources
    [object] $outputs
    
    ArmTemplate([object] $values) : base($values) { }
}
