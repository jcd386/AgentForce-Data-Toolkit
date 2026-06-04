@IsTest
private class AgentSOQLQueryTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Query Account', Industry = 'Technology');
        insert acc;
    }

    @IsTest
    static void testValidQuery() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account LIMIT 5';

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testQueryWithMaxRecords() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account';
        input.maxRecords = 10;

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testQueryWithZeroMaxRecords() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account';
        input.maxRecords = 0;

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testQueryWithExcessiveMaxRecords() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account';
        input.maxRecords = 50000;

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testBlankQuery() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = '';

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testNullQuery() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = null;

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testInvalidSOQL() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id FROM FakeObject__nonexistent LIMIT 1';

        Test.startTest();
        try {
            AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        } catch (Exception e) {
            // expected for invalid object
        }
        Test.stopTest();
    }

    @IsTest
    static void testMalformedSOQL() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'THIS IS NOT SOQL';

        Test.startTest();
        try {
            AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        } catch (Exception e) {
            // expected for malformed query
        }
        Test.stopTest();
    }

    @IsTest
    static void testQueryNoResults() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account WHERE Name = \'zzz_no_match_xyz_impossible_9999\'';

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }

    @IsTest
    static void testBulkInputs() {
        AgentSOQLQuery.Input input1 = new AgentSOQLQuery.Input();
        input1.query = 'SELECT Id, Name FROM Account LIMIT 5';

        AgentSOQLQuery.Input input2 = new AgentSOQLQuery.Input();
        input2.query = 'SELECT Id, Name FROM Contact LIMIT 5';

        List<AgentSOQLQuery.Input> inputs = new List<AgentSOQLQuery.Input>{ input1, input2 };

        Test.startTest();
        List<AgentSOQLQuery.Output> outputs = AgentSOQLQuery.executeQuery(inputs);
        Test.stopTest();
    }

    @IsTest
    static void testQueryWithExistingLimit() {
        AgentSOQLQuery.Input input = new AgentSOQLQuery.Input();
        input.query = 'SELECT Id, Name FROM Account LIMIT 3';
        input.maxRecords = 50;

        Test.startTest();
        AgentSOQLQuery.Output output = AgentSOQLQuery.processInput(input);
        Test.stopTest();
    }
}