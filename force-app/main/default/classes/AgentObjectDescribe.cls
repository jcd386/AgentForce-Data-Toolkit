public with sharing class AgentObjectDescribe {

    public class Input {
        @InvocableVariable(
            required=true
            label='Object API Name'
            description='The API name of the object to describe. Examples: Account, Contact, Opportunity, My_Custom_Object__c'
        )
        public String objectApiName;

        @InvocableVariable(
            required=false
            label='Include Picklist Values'
            description='When true, includes active picklist values. Defaults to false to reduce response size.'
        )
        public Boolean includePicklistValues;

        @InvocableVariable(
            required=false
            label='Include Relationships'
            description='When true, includes parent lookup/master-detail targets and child relationship names. Defaults to false.'
        )
        public Boolean includeRelationships;
    }

    public class Output {
        @InvocableVariable(label='Schema JSON' description='JSON object describing the object schema including objectLabel, objectApiName, isCustom, isCreateable, fieldCount, and a fields array with metadata for each accessible field.')
        public String schemaJson;

        @InvocableVariable(label='Field Count' description='Total number of accessible fields on the object.')
        public Integer fieldCount;

        @InvocableVariable(label='Success' description='True if the object was found and described successfully.')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Description of the error if success is false. Common errors: object does not exist, insufficient access.')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Describe Object Schema'
        description='Returns the complete field-level schema for a Salesforce object including field names, labels, data types, required flags, field lengths, and optionally picklist values and relationship details. Use this action BEFORE creating records to understand required fields and valid data types, or before writing SOQL queries to know which fields are available. Only fields accessible to the current user are included.'
        category='Agent Data Access'
    )
    public static List<Output> describeObject(List<Input> inputs) {
        List<Output> outputs = new List<Output>();
        for (Input input : inputs) {
            outputs.add(processInput(input));
        }
        return outputs;
    }

    @TestVisible
    private static Output processInput(Input input) {
        Output output = new Output();
        try {
            if (String.isBlank(input.objectApiName)) {
                output.success = false;
                output.errorMessage = 'objectApiName is required';
                return output;
            }

            Boolean withPicklists = input.includePicklistValues == true;
            Boolean withRelationships = input.includeRelationships == true;

            // Try the provided name first, then lowercase fallback
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(input.objectApiName);
            if (objectType == null) {
                objectType = Schema.getGlobalDescribe().get(input.objectApiName.toLowerCase());
            }

            if (objectType == null) {
                output.success = false;
                output.errorMessage = 'Object not found: ' + input.objectApiName;
                return output;
            }

            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();

            if (!objDescribe.isAccessible()) {
                output.success = false;
                output.errorMessage = 'Object is not accessible to the current user: ' + input.objectApiName;
                return output;
            }

            // Build fields array
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            List<Map<String, Object>> fieldsList = new List<Map<String, Object>>();

            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();

                if (!fieldDescribe.isAccessible()) {
                    continue;
                }

                Schema.DisplayType fieldType = fieldDescribe.getType();

                Map<String, Object> fieldEntry = new Map<String, Object>{
                    'apiName'    => fieldDescribe.getName(),
                    'label'      => fieldDescribe.getLabel(),
                    'type'       => fieldType.name(),
                    'required'   => (!fieldDescribe.isNillable() && fieldDescribe.isCreateable()),
                    'createable' => fieldDescribe.isCreateable(),
                    'updateable' => fieldDescribe.isUpdateable(),
                    'length'     => fieldDescribe.getLength()
                };

                if (withPicklists && (fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST)) {
                    List<String> activeValues = new List<String>();
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        if (entry.isActive()) {
                            activeValues.add(entry.getValue());
                        }
                    }
                    fieldEntry.put('picklistValues', activeValues);
                }

                if (withRelationships && fieldType == Schema.DisplayType.REFERENCE) {
                    List<String> refTargets = new List<String>();
                    for (Schema.SObjectType refType : fieldDescribe.getReferenceTo()) {
                        refTargets.add(refType.getDescribe().getName());
                    }
                    fieldEntry.put('referenceTo', refTargets);
                    fieldEntry.put('relationshipName', fieldDescribe.getRelationshipName());
                }

                fieldsList.add(fieldEntry);
            }

            // Build schema map
            Map<String, Object> schemaMap = new Map<String, Object>{
                'objectLabel'   => objDescribe.getLabel(),
                'objectApiName' => objDescribe.getName(),
                'isCustom'      => objDescribe.isCustom(),
                'isCreateable'  => objDescribe.isCreateable(),
                'fieldCount'    => fieldsList.size(),
                'fields'        => fieldsList
            };

            // Append child relationships if requested
            if (withRelationships) {
                List<Map<String, Object>> childRelList = new List<Map<String, Object>>();
                for (Schema.ChildRelationship cr : objDescribe.getChildRelationships()) {
                    if (cr.getRelationshipName() == null) {
                        continue;
                    }
                    childRelList.add(new Map<String, Object>{
                        'childObject'      => cr.getChildSObject().getDescribe().getName(),
                        'relationshipName' => cr.getRelationshipName(),
                        'field'            => cr.getField().getDescribe().getName()
                    });
                }
                schemaMap.put('childRelationships', childRelList);
            }

            output.schemaJson  = JSON.serialize(schemaMap);
            output.fieldCount  = fieldsList.size();
            output.success     = true;

        } catch (Exception e) {
            output.success      = false;
            output.errorMessage = e.getMessage();
        }
        return output;
    }
}
