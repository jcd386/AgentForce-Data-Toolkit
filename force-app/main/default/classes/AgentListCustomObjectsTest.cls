@IsTest
private class AgentListCustomObjectsTest {

    @IsTest
    static void testListAllCustomObjects() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testListWithManagedPackageObjects() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();
        input.includeManagedPackageObjects = true;

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testFilterKeyword() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();
        input.filterKeyword = 'Account';

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testFilterKeywordNoMatch() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();
        input.filterKeyword = 'xyznonexistent12345';

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testFilterKeywordBlank() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();
        input.filterKeyword = '';

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testIncludeManagedFalse() {
        AgentListCustomObjects.Input input = new AgentListCustomObjects.Input();
        input.includeManagedPackageObjects = false;

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input }
        );
        Test.stopTest();
    }

    @IsTest
    static void testBulkInput() {
        AgentListCustomObjects.Input input1 = new AgentListCustomObjects.Input();

        AgentListCustomObjects.Input input2 = new AgentListCustomObjects.Input();
        input2.includeManagedPackageObjects = true;
        input2.filterKeyword = 'test';

        Test.startTest();
        List<AgentListCustomObjects.Output> results = AgentListCustomObjects.listCustomObjects(
            new List<AgentListCustomObjects.Input>{ input1, input2 }
        );
        Test.stopTest();
    }
}