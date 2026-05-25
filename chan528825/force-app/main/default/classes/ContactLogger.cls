public class ContactLogger extends ObjectLogger {
    public override void log(List<SObject> records) {
        for (SObject obj : records) {
            Contact con = (Contact)obj;
            System.debug('Contact: ' + con.FirstName + ' ' + con.LastName + ', Email: ' + con.Email);
        }
    }
}