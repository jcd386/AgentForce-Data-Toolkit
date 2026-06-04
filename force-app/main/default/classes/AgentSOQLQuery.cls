public with sharing class AgentSOQLQuery {

    public class Input {
        @InvocableVariable(
            required=true
            label='SOQL Query'
            description='The SOQL query to execute. Examples: "SELECT Id, Name FROM Account LIMIT 10", "SELECT COUNT() FROM Contact WHERE AccountId != null", "SELECT Id, CloseDate, Amount FROM Opportunity WHERE StageName = \'Closed Won\'". Runs in the current user\'s security context — only records the user can access are returned.'
        )
        public String query;

        @InvocableVariable(
            label='Max Records'
            description='Maximum number of records to return. Defaults to 2000 if not provided. Clamped to a maximum of 2000. Ignored for SELECT COUNT() queries (which return a single number) and when the query already contains a LIMIT clause.'
        )
        public Integer maxRecords;
    }

    public class Output {
        @InvocableVariable(label='Results JSON' description='JSON array of query results. Each element is a map of field API names to values.')
        public String resultsJson;

        @InvocableVariable(label='Record Count' description='Number of records returned by the query.')
        public Integer recordCount;

        @InvocableVariable(label='Success' description='True if the query executed without errors, false otherwise.')
        public Boolean success;

        @InvocableVariable(label='Error Message' description='Description of the error if the query failed. Empty when success is true.')
        public String errorMessage;
    }

    @InvocableMethod(
        label='Execute SOQL Query'
        description='Executes a SOQL query and returns the results as JSON. Use this to look up records, search data, get counts, or retrieve field values from any accessible Salesforce object. The query runs with the current user sharing rules so only records the user can access are returned. Always include a LIMIT clause to control result size.'
        category='Agent Data Access'
    )
    public static List<Output> executeQuery(List<Input> inputs) {
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
            if (String.isBlank(input.query)) {
                output.success = false;
                output.errorMessage = 'Query is required';
                return output;
            }

            Integer maxRows = (input.maxRecords == null) ? 2000 : input.maxRecords;
            maxRows = Math.max(1, Math.min(maxRows, 2000));

            String soql = input.query;

            // Detect SELECT COUNT() with no field arg — Salesforce requires Database.countQuery() for these
            // and forbids a LIMIT clause. Match patterns like "SELECT COUNT() FROM ..." with optional whitespace.
            Pattern countPattern = Pattern.compile('(?i)^\\s*SELECT\\s+COUNT\\s*\\(\\s*\\)\\s+FROM\\s+');
            Boolean isCountQuery = countPattern.matcher(soql).find();

            if (isCountQuery) {
                Integer count = Database.countQuery(soql);
                output.resultsJson = '[{"count":' + count + '}]';
                output.recordCount = count;
                output.success = true;
            } else {
                if (!soql.toLowerCase().contains(' limit ')) {
                    soql = soql + ' LIMIT ' + maxRows;
                }
                List<SObject> records = Database.query(soql);
                output.resultsJson = JSON.serialize(records);
                output.recordCount = records.size();
                output.success = true;
            }
        } catch (Exception e) {
            output.success = false;
            output.errorMessage = 'Query error: ' + e.getMessage();
            output.recordCount = 0;
            output.resultsJson = '[]';
        }
        return output;
    }
}