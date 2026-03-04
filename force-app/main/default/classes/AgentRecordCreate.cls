public with sharing class AgentRecordCreate {

    public class Input {
        @InvocableVariable(
            required=true
            label='Object API Name'
            description='The API name of the Salesforce object. Examples: Account, Contact, Opportunity, Case, my_custom_object__c. Tip: call Describe Object Schema first to get the correct API name and learn which fields are required.'
        )
        public String objectApiName;

        @InvocableVariable(
            required=true
            label='Field Values JSON'
            description='A JSON object mapping field API names to the values to set. Example: {"Name": "Acme Corp", "Industry": "Technology", "Phone": "555-1234"}. Use date format YYYY-MM-DD, datetime format YYYY-MM-DDTHH:MM:SSZ, booleans as true or false, and numbers without currency symbols or commas. When updating, only include the fields you want to change.'
        )
        public String fieldValuesJson;

        @InvocableVariable(
            label='Record ID'
            description='Optional. When provided, updates the existing record with this ID instead of creating a new one. Only the fields specified in Field Values JSON will be changed; all other fields remain untouched.'
        )
        public String recordId;
    }

    public class Output {
        @InvocableVariable(label='Record ID' description='The ID of the created or updated record. Only populated on success.')
        public String recordId;

        @InvocableVariable(label='Success' description='True if the record was created or updated successfully.')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Description of the error if success is false. Common errors: required field missing, invalid field value, insufficient access, validation rule failure, record not found.')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Create or Update Record'
        description='Creates a new record or updates an existing one. To create: provide the Object API Name and Field Values JSON with all required fields. To update: also provide the Record ID and only the fields you want to change. Call Describe Object Schema first to learn required fields and data types. Supports text, number, date (YYYY-MM-DD), datetime (YYYY-MM-DDTHH:MM:SSZ), boolean, and picklist fields.'
        category='Agent Data Access'
    )
    public static List<Output> createRecord(List<Input> inputs) {
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
                output.errorMessage = 'Object API name is required';
                return output;
            }

            if (String.isBlank(input.fieldValuesJson)) {
                output.success = false;
                output.errorMessage = 'Field values JSON is required';
                return output;
            }

            Map<String, Object> fieldValues;
            try {
                fieldValues = (Map<String, Object>) JSON.deserializeUntyped(input.fieldValuesJson);
            } catch (Exception e) {
                output.success = false;
                output.errorMessage = 'Invalid JSON: ' + e.getMessage();
                return output;
            }

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(input.objectApiName.toLowerCase());
            if (objectType == null) {
                output.success = false;
                output.errorMessage = 'Object \'' + input.objectApiName + '\' does not exist or is not accessible';
                return output;
            }

            Boolean isUpdate = String.isNotBlank(input.recordId);
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();

            if (!isUpdate && !objectDescribe.isCreateable()) {
                output.success = false;
                output.errorMessage = 'Object \'' + input.objectApiName + '\' is not createable';
                return output;
            }
            if (isUpdate && !objectDescribe.isUpdateable()) {
                output.success = false;
                output.errorMessage = 'Object \'' + input.objectApiName + '\' is not updateable';
                return output;
            }

            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            SObject record;
            if (isUpdate) {
                record = objectType.newSObject(Id.valueOf(input.recordId));
            } else {
                record = objectType.newSObject();
            }

            for (String fieldName : fieldValues.keySet()) {
                Schema.SObjectField fieldToken = fieldMap.get(fieldName.toLowerCase());
                if (fieldToken == null) {
                    output.success = false;
                    output.errorMessage = 'Field \'' + fieldName + '\' does not exist on ' + objectDescribe.getName();
                    return output;
                }

                Schema.DescribeFieldResult fdr = fieldToken.getDescribe();

                if (isUpdate && !fdr.isUpdateable()) {
                    continue;
                }
                if (!isUpdate && !fdr.isCreateable()) {
                    continue;
                }

                Object rawValue = fieldValues.get(fieldName);
                if (rawValue == null) {
                    record.put(fdr.getName(), null);
                    continue;
                }

                Object converted = convertValue(rawValue, fdr);
                record.put(fdr.getName(), converted);
            }

            Database.SaveResult sr;
            if (isUpdate) {
                sr = Database.update(record, false);
            } else {
                sr = Database.insert(record, false);
            }

            if (sr.isSuccess()) {
                output.recordId = sr.getId();
                output.success = true;
            } else {
                List<String> errors = new List<String>();
                for (Database.Error err : sr.getErrors()) {
                    errors.add(err.getMessage());
                }
                output.success = false;
                output.errorMessage = String.join(errors, '; ');
            }

        } catch (Exception e) {
            output.success = false;
            output.errorMessage = e.getMessage();
        }
        return output;
    }

    @TestVisible
    private static Object convertValue(Object rawValue, Schema.DescribeFieldResult fdr) {
        Schema.DisplayType fieldType = fdr.getType();
        String strValue = String.valueOf(rawValue);

        switch on fieldType {
            when STRING, TEXTAREA, URL, EMAIL, PHONE, ID, ENCRYPTEDSTRING {
                return String.valueOf(rawValue);
            }
            when PICKLIST, MULTIPICKLIST {
                return String.valueOf(rawValue);
            }
            when BOOLEAN {
                if (rawValue instanceof Boolean) {
                    return rawValue;
                }
                return Boolean.valueOf(strValue);
            }
            when INTEGER {
                if (rawValue instanceof Integer) {
                    return rawValue;
                }
                return Integer.valueOf(strValue);
            }
            when DOUBLE, CURRENCY, PERCENT {
                if (rawValue instanceof Decimal) {
                    return rawValue;
                }
                if (rawValue instanceof Integer) {
                    return Decimal.valueOf((Integer) rawValue);
                }
                String cleaned = strValue.replaceAll('[^0-9\\.\\-]', '');
                return Decimal.valueOf(cleaned);
            }
            when DATE {
                return Date.valueOf(strValue);
            }
            when DATETIME {
                String normalized = strValue.replace('T', ' ').removeEnd('Z');
                return Datetime.valueOf(normalized);
            }
            when BASE64 {
                return EncodingUtil.base64Decode(strValue);
            }
            when REFERENCE {
                return Id.valueOf(strValue);
            }
            when else {
                return String.valueOf(rawValue);
            }
        }
    }
}
