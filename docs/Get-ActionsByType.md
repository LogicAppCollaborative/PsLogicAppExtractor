---
external help file: PsLogicAppExtractor-help.xml
Module Name: PsLogicAppExtractor
online version:
schema: 2.0.0
---

# Get-ActionsByType

## SYNOPSIS
Get action from the object, filtered by the type of the action

## SYNTAX

```
Get-ActionsByType [[-InputObject] <PSObject>] [[-Type] <String>]
```

## DESCRIPTION
Get actions and all nested actions, filtered by type

## EXAMPLES

### EXAMPLE 1
```
Get-ActionsByType -InputObject $obj -Type "Http"
```

Will traverse the $obj and filter actions to only output the ones of the type Http

## PARAMETERS

### -InputObject
The object that you want to work against

Will by analyzed to see if it has nested actions, and will be recursively traversed to fetch all actions

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
The action type that will be outputted

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Author: Mötz Jensen (@Splaxi)

## RELATED LINKS
