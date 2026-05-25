public class AccountLogger extends ObjectLogger {
    public override void log(List<SObject> records) {
        for (SObject obj : records) {
            Account acc = (Account)obj;
            System.debug('Account: ' + acc.Name + ', Industry: ' + acc.Industry);
        }
    }
}