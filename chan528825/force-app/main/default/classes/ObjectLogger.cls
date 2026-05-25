public virtual class ObjectLogger {
    public virtual void log(List<SObject> records) {
        System.debug('Logging generic SObjects: ' + records.size());
    }
}