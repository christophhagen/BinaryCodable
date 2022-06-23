import Foundation

struct SuperEncoderKey: CodingKey {
    
    init?(stringValue: String) {
        
    }
    
    init?(intValue: Int) {
        
    }
    
    init() { }
    
    var stringValue: String {
        "super"
    }
    
    var intValue: Int? {
        0
    }
}
