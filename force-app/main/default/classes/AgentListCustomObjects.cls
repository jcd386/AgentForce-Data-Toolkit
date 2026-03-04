public with sharing class AgentListCustomObjects {

    public class Input {
        @InvocableVariable(
            required=false
            label='Include Managed Package Objects'
            description='When true, includes custom objects from installed managed packages (objects with a namespace prefix like ns__Object__c). Defaults to false to show only objects created in this org.'
        )
        public Boolean includeManagedPackageObjects;

        @InvocableVariable(
            required=false
            label='Filter Keyword'
            description='Optional keyword to filter the results. Only objects whose API name or label contains this text (case-insensitive) are returned. Leave blank to return all custom objects.'
        )
        public String filterKeyword;
    }

    public class Output {
        @InvocableVariable(label='Objects JSON' description='JSON array of custom objects. Each element contains apiName, label, pluralLabel, isCreateable, isQueryable, and keyPrefix. Parse this to find the object you need.')
        public String objectsJson;

        @InvocableVariable(label='Object Count' description='Total number of custom objects returned. Use this to confirm results were found before parsing the JSON.')
        public Integer objectCount;

        @InvocableVariable(label='Success' description='True if the custom objects were retrieved successfully.')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Description of the error if success is false. Empty when success is true.')
        public String errorMessage;
    }

    @InvocableMethod(
        label='List Custom Objects'
        description='Returns a list of all custom objects in the Salesforce org with their API names, labels, and key metadata. Use this action to discover what custom objects exist before querying or creating records. By default only shows objects created in this org — set includeManagedPackageObjects to true to also see objects from installed packages.'
        category='Agent Data Access'
    )
    public static List<Output> listCustomObjects(List<Input> inputs) {
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
            Boolean includeManaged = input.includeManagedPackageObjects == true;
            String keyword = String.isNotBlank(input.filterKeyword)
                ? input.filterKeyword.toLowerCase()
                : null;

            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            List<Map<String, Object>> objectsList = new List<Map<String, Object>>();

            for (String objectName : globalDescribe.keySet()) {
                // Only include custom objects (ending in __c)
                if (!objectName.endsWith('__c')) {
                    continue;
                }

                Schema.DescribeSObjectResult objDescribe = globalDescribe.get(objectName).getDescribe();

                // Skip if not accessible
                if (!objDescribe.isAccessible()) {
                    continue;
                }

                String apiName = objDescribe.getName();

                // Skip managed package objects unless requested
                if (!includeManaged && apiName.countMatches('__') > 1) {
                    continue;
                }

                // Apply keyword filter
                if (keyword != null) {
                    String lowerApiName = apiName.toLowerCase();
                    String lowerLabel = objDescribe.getLabel().toLowerCase();
                    if (!lowerApiName.contains(keyword) && !lowerLabel.contains(keyword)) {
                        continue;
                    }
                }

                objectsList.add(new Map<String, Object>{
                    'apiName'      => apiName,
                    'label'        => objDescribe.getLabel(),
                    'pluralLabel'  => objDescribe.getLabelPlural(),
                    'isCreateable' => objDescribe.isCreateable(),
                    'isQueryable'  => objDescribe.isQueryable(),
                    'keyPrefix'    => objDescribe.getKeyPrefix()
                });
            }

            // Sort by label for consistent output
            objectsList.sort(new ObjectLabelComparator());

            output.objectsJson  = JSON.serialize(objectsList);
            output.objectCount  = objectsList.size();
            output.success      = true;

        } catch (Exception e) {
            output.success      = false;
            output.errorMessage = e.getMessage();
        }
        return output;
    }

    private class ObjectLabelComparator implements System.Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            String labelA = (String) a.get('label');
            String labelB = (String) b.get('label');
            if (labelA == null) labelA = '';
            if (labelB == null) labelB = '';
            return labelA.compareTo(labelB);
        }
    }
}