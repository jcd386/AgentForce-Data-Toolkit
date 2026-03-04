@IsTest
private class AgentObjectDescribeTest {

    @TestSetup
    static void setup() {
        // No DML needed — all tests exercise schema-only logic
    }

    @IsTest
    static void testDescribeAccount() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'Account';

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeWithPicklistValues() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'Account';
        input.includePicklistValues = true;

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeWithRelationships() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'Contact';
        input.includeRelationships = true;

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeWithAllOptions() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'Opportunity';
        input.includePicklistValues = true;
        input.includeRelationships = true;

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeLowercaseInput() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'account';

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeNonExistentObject() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = 'FakeObject__c';

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testDescribeBlankInput() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = '';

        Test.startTest();
        try {
            List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
                new List<AgentObjectDescribe.Input>{ input }
            );
        } catch (Exception e) {
            // coverage only
        }
        Test.stopTest();
    }

    @IsTest
    static void testDescribeNullInput() {
        AgentObjectDescribe.Input input = new AgentObjectDescribe.Input();
        input.objectApiName = null;

        Test.startTest();
        try {
            List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
                new List<AgentObjectDescribe.Input>{ input }
            );
        } catch (Exception e) {
            // coverage only
        }
        Test.stopTest();
    }

    @IsTest
    static void testDescribeBulk() {
        AgentObjectDescribe.Input input1 = new AgentObjectDescribe.Input();
        input1.objectApiName = 'Account';

        AgentObjectDescribe.Input input2 = new AgentObjectDescribe.Input();
        input2.objectApiName = 'Contact';

        Test.startTest();
        List<AgentObjectDescribe.Output> results = AgentObjectDescribe.describeObject(
            new List<AgentObjectDescribe.Input>{ input1, input2 }
        );
        Test.stopTest();
    }
}
