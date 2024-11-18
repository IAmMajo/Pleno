public data class SendEmailDTO {
    public var receiver : String
    public var subject : String
    public var message : String?
    public var template : String?
    public var templateData : Map<String, String>?
}
