@IsTest
private class AgentRecordCreateTest {

    private static AgentRecordCreate.Input buildInput(String objectApiName, String fieldValuesJson) {
        AgentRecordCreate.Input input = new AgentRecordCreate.Input();
        input.objectApiName = objectApiName;
        input.fieldValuesJson = fieldValuesJson;
        return input;
    }

    private static AgentRecordCreate.Input buildUpdateInput(String objectApiName, String recordId, String fieldValuesJson) {
        AgentRecordCreate.Input input = new AgentRecordCreate.Input();
        input.objectApiName = objectApiName;
        input.recordId = recordId;
        input.fieldValuesJson = fieldValuesJson;
        return input;
    }

    @IsTest
    static void testCreateAccount() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Test Agent Account"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateContact() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Contact', '{"LastName": "Agent Test", "Email": "test@test.com"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithNumericFields() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Numeric Test Account", "NumberOfEmployees": 50, "AnnualRevenue": 1250000.00}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithBooleanField() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Contact', '{"LastName": "Boolean Test", "DoNotCall": true}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithDateField() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Opportunity', '{"Name": "Date Test Opp", "StageName": "Prospecting", "CloseDate": "2026-12-31"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithPicklistField() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Picklist Test Account", "Industry": "Technology"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateMissingRequiredField() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Industry": "Technology"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateNonExistentObject() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('FakeObject__c', '{"Name": "Should Fail"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateNonExistentField() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Field Test", "FakeField__c": "Bad Value"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateInvalidJson() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', 'this is not json')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateBlankObject() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('', '{"Name": "Test"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateBlankJson() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateNullInputs() {
        Test.startTest();
        try {
            AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
                buildInput(null, null)
            });
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateBulk() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Bulk Account One"}'),
            buildInput('Account', '{"Name": "Bulk Account Two"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithNullFieldValue() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildInput('Account', '{"Name": "Null Field Test", "Industry": null}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testCreateWithNonCreateableField() {
        Test.startTest();
        try {
            AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
                buildInput('Account', '{"Name": "Skip Test", "Id": "001000000000000AAA"}')
            });
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateAccount() {
        Account acc = new Account(Name = 'Original Name');
        insert acc;
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildUpdateInput('Account', acc.Id, '{"Name": "Updated Name", "Industry": "Technology"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testUpdateWithNullField() {
        Account acc = new Account(Name = 'Null Update Test', Industry = 'Technology');
        insert acc;
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildUpdateInput('Account', acc.Id, '{"Industry": null}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testUpdateNonExistentRecord() {
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildUpdateInput('Account', '001000000000000AAA', '{"Name": "Ghost Record"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testUpdateNonExistentField() {
        Account acc = new Account(Name = 'Field Test');
        insert acc;
        Test.startTest();
        AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
            buildUpdateInput('Account', acc.Id, '{"FakeField__c": "Bad Value"}')
        });
        Test.stopTest();
    }

    @IsTest
    static void testUpdateWithNonUpdateableField() {
        Account acc = new Account(Name = 'Skip Update Test');
        insert acc;
        Test.startTest();
        try {
            AgentRecordCreate.createRecord(new List<AgentRecordCreate.Input>{
                buildUpdateInput('Account', acc.Id, '{"Name": "New Name", "CreatedDate": "2026-01-01T00:00:00Z"}')
            });
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}
